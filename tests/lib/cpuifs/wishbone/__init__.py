from ..base import CpuifTestMode

from peakrdl_regblock.cpuif.wishbone import Wishbone_Cpuif as SvWishbone_Cpuif
from peakrdl_regblock.cpuif.wishbone import Wishbone_Cpuif_flattened as SvWishbone_Cpuif_flattened
from peakrdl_regblock_vhdl.cpuif.wishbone import Wishbone_Cpuif as VhdlWishbone_Cpuif
from peakrdl_regblock_vhdl.cpuif.wishbone import Wishbone_Cpuif_flattened as VhdlWishbone_Cpuif_flattened

class Wishbone(CpuifTestMode):
    sv_cpuif_cls = SvWishbone_Cpuif
    vhdl_cpuif_cls = VhdlWishbone_Cpuif
    rtl_files = [
        "../../../hdl-src/wishbone_intf.sv",
        "../../../../hdl-src/wishbone_intf_pkg.vhd",
    ]
    tb_files = [
        "../../../hdl-src/wishbone_intf.sv",
        "../../../../hdl-src/wishbone_intf_pkg.vhd",
        "wishbone_intf_driver.sv",
    ]
    tb_template = "tb_inst.sv"

    @staticmethod
    def input_signals(cpuif: SvWishbone_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("we",   False, 1),
            ("stb",  False, 1),
            ("cyc",  False, 1),
            ("adr",  True,  cpuif.addr_width),
            ("odat", True,  cpuif.data_width),
            ("sel",  True,  cpuif.data_width_bytes),
        ]

    @staticmethod
    def output_signals(cpuif: SvWishbone_Cpuif) -> "list[tuple[str, bool, int]]":
        """Return tuples of (name, is_vector, width)"""
        return [
            ("ack",   False, 1),
            ("err",   False, 1),
            ("stall", False, 1),
            ("idat",  True,  cpuif.data_width),
        ]


class FlatWishbone(Wishbone):
    sv_cpuif_cls = SvWishbone_Cpuif_flattened
    vhdl_cpuif_cls = VhdlWishbone_Cpuif_flattened
    rtl_files = []
