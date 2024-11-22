from ..base import CpuifTestMode

from peakrdl_regblock.cpuif.axi4lite import AXI4Lite_Cpuif as SvAXI4Lite_Cpuif
from peakrdl_regblock.cpuif.axi4lite import AXI4Lite_Cpuif_flattened as SvAXI4Lite_Cpuif_flattened
from peakrdl_regblock_vhdl.cpuif.axi4lite import AXI4Lite_Cpuif as VhdlAXI4Lite_Cpuif
from peakrdl_regblock_vhdl.cpuif.axi4lite import AXI4Lite_Cpuif_flattened as VhdlAXI4Lite_Cpuif_flattened

class AXI4Lite(CpuifTestMode):
    sv_cpuif_cls = SvAXI4Lite_Cpuif
    vhdl_cpuif_cls = VhdlAXI4Lite_Cpuif
    rtl_files = [
        "../../../hdl-src/axi4lite_intf.sv",
        "../../../../hdl-src/axi4lite_intf_pkg.vhd",
    ]
    tb_files = [
        "../../../hdl-src/axi4lite_intf.sv",
        "../../../../hdl-src/axi4lite_intf_pkg.vhd",
        "axi4lite_intf_driver.sv",
    ]
    tb_template = "tb_inst.sv"

    @staticmethod
    def input_signals(cpuif: SvAXI4Lite_Cpuif) -> list[tuple[str, bool, int]]:
        """Return tuples of (name, is_vector, width)"""
        return [
            ("awvalid", False, 1),
            ("awaddr",  True,  cpuif.addr_width),
            ("awprot",  True,  3),
            ("wvalid",  False, 1),
            ("wdata",   True,  cpuif.data_width),
            ("wstrb",   True,  cpuif.data_width_bytes),
            ("bready",  False, 1),
            ("arvalid", False, 1),
            ("araddr",  True,  cpuif.addr_width),
            ("arprot",  True,  3),
            ("rready",  False, 1),
        ]

    @staticmethod
    def output_signals(cpuif: SvAXI4Lite_Cpuif) -> list[tuple[str, bool, int]]:
        """Return tuples of (name, is_vector, width)"""
        return [
            ("awready", False, 1),
            ("wready",  False, 1),
            ("bvalid",  False, 1),
            ("bresp",   True,  2),
            ("arready", False, 1),
            ("rvalid",  False, 1),
            ("rdata",   True,  cpuif.data_width),
            ("rresp",   True,  2),
        ]


class FlatAXI4Lite(AXI4Lite):
    sv_cpuif_cls = SvAXI4Lite_Cpuif_flattened
    vhdl_cpuif_cls = VhdlAXI4Lite_Cpuif_flattened
    rtl_files = []
