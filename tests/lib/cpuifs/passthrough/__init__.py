from ..base import CpuifTestMode

from peakrdl_regblock.cpuif.passthrough import PassthroughCpuif as SvPassthroughCpuif
from peakrdl_regblock_vhdl.cpuif.passthrough import PassthroughCpuif as VhdlPassthroughCpuif

class Passthrough(CpuifTestMode):
    sv_cpuif_cls = SvPassthroughCpuif
    vhdl_cpuif_cls = VhdlPassthroughCpuif
    rtl_files = []
    tb_files = [
        "passthrough_driver.sv",
    ]
    tb_template = "tb_inst.sv"

    @staticmethod
    def input_signals(cpuif: SvPassthroughCpuif) -> list[tuple[str, bool, int]]:
        """Return tuples of (name, is_vector, width)"""
        return [
            ("s_cpuif_req",       False, 1),
            ("s_cpuif_req_is_wr", False, 1),
            ("s_cpuif_addr",      True,  cpuif.addr_width),
            ("s_cpuif_wr_data",   True,  cpuif.data_width),
            ("s_cpuif_wr_biten",  True,  cpuif.data_width),
        ]

    @staticmethod
    def output_signals(cpuif: SvPassthroughCpuif) -> list[tuple[str, bool, int]]:
        """Return tuples of (name, is_vector, width)"""
        return [
            ("s_cpuif_req_stall_wr", False, 1),
            ("s_cpuif_req_stall_rd", False, 1),
            ("s_cpuif_rd_ack",       False, 1),
            ("s_cpuif_rd_err",       False, 1),
            ("s_cpuif_rd_data",      True,  cpuif.data_width),
            ("s_cpuif_wr_ack",       False, 1),
            ("s_cpuif_wr_err",       False, 1),
        ]
