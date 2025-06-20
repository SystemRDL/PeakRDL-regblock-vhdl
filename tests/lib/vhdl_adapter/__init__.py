import os
from itertools import product

import jinja2 as jj
from systemrdl.walker import RDLWalker
from systemrdl.node import Node

from peakrdl_regblock import RegblockExporter as SvRegblockExporter
from peakrdl_regblock_vhdl import RegblockExporter as VhdlRegblockExporter
from peakrdl_regblock.hwif.generators import InputStructGenerator_Hier, OutputStructGenerator_Hier
from peakrdl_regblock_vhdl.identifier_filter import kw_filter

from ...lib.cpuifs.base import CpuifTestMode


class VhdlAdapter:
    """Adapter to test VHDL regblock using SV testbenches"""
    def __init__(self, sv_exporter: SvRegblockExporter, vhdl_exporter: VhdlRegblockExporter, cpuif_test_cls: CpuifTestMode):
        self.sv_exporter = sv_exporter
        self.vhdl_exporter = vhdl_exporter
        self.cpuif_test_cls = cpuif_test_cls

        loader = jj.ChoiceLoader([
            jj.FileSystemLoader(os.path.dirname(__file__)),
            jj.PrefixLoader({
                'base': jj.FileSystemLoader(os.path.dirname(__file__)),
            }, delimiter=":")
        ])

        self.jj_env = jj.Environment(
            loader=loader,
            undefined=jj.StrictUndefined,
        )

    def export(self, output_dir:str):

        hwif_signals = SvInputStructSignals(self.sv_exporter.hwif).get_signals(self.sv_exporter.ds.top_node)
        hwif_signals += SvOutputStructSignals(self.sv_exporter.hwif).get_signals(self.sv_exporter.ds.top_node)
        cpuif_signals = self.cpuif_test_cls.signals(self.sv_exporter.cpuif)
        cpuif_signals_in = self.cpuif_test_cls.input_signals(self.sv_exporter.cpuif)
        cpuif_signals_out = self.cpuif_test_cls.output_signals(self.sv_exporter.cpuif)

        # CPUIFs with flattened variants have a ".signal()" method that returns the given bus signal name
        # with the appropriate prefix. The adapter templates rely on this behavior, but it's not implemented
        # for the passthrough CPUIF. Hack it in.
        if not hasattr(self.sv_exporter.cpuif, "signal"):
            self.sv_exporter.cpuif.signal = lambda x: x
        if not hasattr(self.vhdl_exporter.cpuif, "signal"):
            self.vhdl_exporter.cpuif.signal = lambda x: x

        context = {
            "sv_cpuif": self.sv_exporter.cpuif,
            "vhdl_cpuif": self.vhdl_exporter.cpuif,
            "cpuif_signals" : cpuif_signals,
            "cpuif_signals_in" : cpuif_signals_in,
            "cpuif_signals_out" : cpuif_signals_out,
            "ds": self.sv_exporter.ds,
            "hwif": self.sv_exporter.hwif,
            "hwif_signals": hwif_signals,
            "default_resetsignal_name": self.sv_exporter.dereferencer.default_resetsignal_name,
            "hwif_sv_to_vhdl": hwif_sv_to_vhdl,
            "kwf": kw_filter,
        }

        # Write out design
        os.makedirs(output_dir, exist_ok=True)
        for (adapter_name, adapter_tmpl) in (
            ("regblock_adapter.sv", "test_adapter_tmpl.sv"),
            ("regblock_adapter.vhd", "test_adapter_tmpl.vhd"),
        ):
            adapter_file_path = os.path.join(output_dir, adapter_name)
            template = self.jj_env.get_template(adapter_tmpl)
            stream = template.stream(context)
            stream.dump(adapter_file_path)


def hwif_sv_to_vhdl(identifier: str) -> str:
    """Convert SV indexing to VHDL matrix indexing. Also change `next` to `next_q`.

    For example, `reg[6].something[1][2][3].next` becomes `reg(6).something(1, 2, 3).next_q`.
    """
    result = identifier.replace("][", ", ").replace("[", "(").replace("]", ")")
    if result.endswith(".next"):
        result += "_q"
    return result


class SvInputStructSignals(InputStructGenerator_Hier):
    """Monitor signals added via "add_member" to produce a list of HWIF
    input signals and their widths
    """
    def get_signals(self, node: 'Node') -> "list[tuple[str, int]]":
        self.signals = set()
        self.start("don't care")

        walker = RDLWalker(unroll=False)
        walker.walk(node, self, skip_top=True)

        self.finish()
        return sorted(self.signals)

    def add_member(self, name: str, width: int = 1) -> None:
        super().add_member(name, width)
        prefixes = ["hwif_in"]
        for s in self._struct_stack:
            if s.inst_name is None:
                continue
            prefixes = [prefix + "." + s.inst_name for prefix in prefixes]
            if s.array_dimensions:
                new_prefixes = []
                dim_ranges = [range(dim) for dim in s.array_dimensions]
                for indices in product(*dim_ranges):
                    new_prefixes.extend([prefix + "[" + "][".join(map(str, indices)) + "]" for prefix in prefixes])
                prefixes = new_prefixes

        # VHDL doesn't support packed structs, and uses std_logic_vectors instead.
        # If the innermost struct is packed, then make sure the struct instance itself is represented,
        # but not any members of the packed struct.
        if self._struct_stack[-1].packed:
            width = self.hwif.ds.cpuif_data_width # FIXME: this does not take into account the "regwidth" property
            self.signals.update((prefix, width) for prefix in prefixes)
        else:
            self.signals.update((f"{prefix}.{name}", width) for prefix in prefixes)


class SvOutputStructSignals(OutputStructGenerator_Hier):
    """Monitor signals added via "add_member" to produce a list of HWIF
    output signals and their widths
    """
    def get_signals(self, node: 'Node') -> "list[tuple[str, int]]":
        self.signals = set()
        self.start("don't care")

        walker = RDLWalker(unroll=False)
        walker.walk(node, self, skip_top=True)

        self.finish()
        return sorted(self.signals)

    def add_member(self, name: str, width: int = 1) -> None:
        super().add_member(name, width)
        prefixes = ["hwif_out"]
        for s in self._struct_stack:
            if s.inst_name is None:
                continue
            prefixes = [prefix + "." + s.inst_name for prefix in prefixes]
            if s.array_dimensions:
                new_prefixes = []
                dim_ranges = [range(dim) for dim in s.array_dimensions]
                for indices in product(*dim_ranges):
                    new_prefixes.extend([prefix + "[" + "][".join(map(str, indices)) + "]" for prefix in prefixes])
                prefixes = new_prefixes

        # VHDL doesn't support packed structs, and uses std_logic_vectors instead.
        # If the innermost struct is packed, then make sure the struct instance itself is represented,
        # but not any members of the packed struct.
        if self._struct_stack[-1].packed:
            width = self.hwif.ds.cpuif_data_width # FIXME: this does not take into account the "regwidth" property
            self.signals.update((prefix, width) for prefix in prefixes)
        else:
            self.signals.update([(f"{prefix}.{name}", width) for prefix in prefixes])
