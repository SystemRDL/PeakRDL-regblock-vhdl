from ..base import CpuifTestMode

from peakrdl_regblock.cpuif.obi import OBI_Cpuif as SvOBI_Cpuif
from peakrdl_regblock.cpuif.obi import OBI_Cpuif_flattened as SvOBI_Cpuif_flattened
from peakrdl_regblock_vhdl.cpuif.obi import OBI_Cpuif as VhdlOBI_Cpuif
from peakrdl_regblock_vhdl.cpuif.obi import OBI_Cpuif_flattened as VhdlOBI_Cpuif_flattened

class OBI(CpuifTestMode):
    sv_cpuif_cls = SvOBI_Cpuif
    vhdl_cpuif_cls = VhdlOBI_Cpuif
    rtl_files = [
        "../../../hdl-src/obi_intf.sv",
        "../../../../hdl-src/obi_intf_pkg.vhd",
    ]
    tb_files = [
        "../../../hdl-src/obi_intf.sv",
        "../../../../hdl-src/obi_intf_pkg.vhd",
        "obi_intf_driver.sv",
    ]
    tb_template = "tb_inst.sv"

    @staticmethod
    def input_signals(cpuif: SvOBI_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("req",    False, 1),
            ("addr",   True,  cpuif.addr_width),
            ("we",     False, 1),
            ("be",     True,  cpuif.data_width_bytes),
            ("wdata",  True,  cpuif.data_width),
            ("aid",    True,  1),
            ("rready", False, 1),
        ]

    @staticmethod
    def output_signals(cpuif: SvOBI_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("gnt",     False, 1),
            ("rvalid",  False, 1),
            ("rdata",   True,  cpuif.data_width),
            ("err",     False, 1),
            ("rid",     True,  1),
        ]


class FlatOBI(OBI):
    sv_cpuif_cls = SvOBI_Cpuif_flattened
    vhdl_cpuif_cls = VhdlOBI_Cpuif_flattened
    rtl_files = []
