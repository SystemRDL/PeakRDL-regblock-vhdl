from ..base import CpuifTestMode

from peakrdl_regblock.cpuif.avalon import Avalon_Cpuif as SvAvalon_Cpuif
from peakrdl_regblock.cpuif.avalon import Avalon_Cpuif_flattened as SvAvalon_Cpuif_flattened
from peakrdl_regblock_vhdl.cpuif.avalon import Avalon_Cpuif as VhdlAvalon_Cpuif
from peakrdl_regblock_vhdl.cpuif.avalon import Avalon_Cpuif_flattened as VhdlAvalon_Cpuif_flattened

class Avalon(CpuifTestMode):
    sv_cpuif_cls = SvAvalon_Cpuif
    vhdl_cpuif_cls = VhdlAvalon_Cpuif
    rtl_files = [
        "../../../hdl-src/avalon_mm_intf.sv",
        "../../../../hdl-src/avalon_mm_intf_pkg.vhd",
    ]
    tb_files = [
        "../../../hdl-src/avalon_mm_intf.sv",
        "../../../../hdl-src/avalon_mm_intf_pkg.vhd",
        "avalon_mm_intf_driver.sv",
    ]
    tb_template = "tb_inst.sv"

    @staticmethod
    def input_signals(cpuif: SvAvalon_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("read",       False, 1),
            ("write",      False, 1),
            ("address",    True,  cpuif.word_addr_width),
            ("writedata",  True,  cpuif.data_width),
            ("byteenable", True,  cpuif.data_width_bytes),
        ]

    @staticmethod
    def output_signals(cpuif: SvAvalon_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("waitrequest",        False, 1),
            ("readdatavalid",      False, 1),
            ("writeresponsevalid", False, 1),
            ("readdata",           True,  cpuif.data_width),
            ("response",           True,  2),
        ]


class FlatAvalon(Avalon):
    sv_cpuif_cls = SvAvalon_Cpuif_flattened
    vhdl_cpuif_cls = VhdlAvalon_Cpuif_flattened
    rtl_files = []
