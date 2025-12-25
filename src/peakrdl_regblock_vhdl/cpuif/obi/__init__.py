from typing import List, Union

from ..base import CpuifBase

class OBI_Cpuif(CpuifBase):
    template_path = "obi_tmpl.vhd"
    is_interface = True

    @property
    def package_name(self) -> Union[str, None]:
        return "obi_intf_pkg"

    @property
    def port_declaration(self) -> str:
        return "\n".join([
            "s_obi_i : in obi_subordinate_in_intf(",
           f"    addr({self.addr_width-1} downto 0),",
           f"    be({self.data_width_bytes-1} downto 0),",
           f"    wdata({self.data_width-1} downto 0)",
            ");",
            "s_obi_o : out obi_subordinate_out_intf(",
           f"   rdata({self.data_width-1} downto 0)",
            ")",
        ])

    @property
    def signal_declaration(self) -> str:
        return "\n".join([
            "signal is_active   : std_logic;  -- A request is being served (not yet fully responded)",
            "signal gnt_q       : std_logic;  -- one-cycle grant for A-channel",
            "signal rsp_pending : std_logic;  -- response ready but not yet accepted by manager",
           f"signal rsp_rdata_q : {self.signal('rdata')}'subtype;",
            "signal rsp_err_q   : std_logic;",
           f"signal rid_q       : {self.signal('rid')}'subtype;",
        ])

    def signal(self, name: str) -> str:
        if name.lower().endswith(("gnt", "rvalid", "rdata", "err", "rid")):
            return "s_obi_o." + name.lower()
        else:
            return "s_obi_i." + name.lower()

    @property
    def regblock_latency(self) -> int:
        return max(self.exp.ds.min_read_latency, self.exp.ds.min_write_latency)

    @property
    def max_outstanding(self) -> int:
        """
        OBI supports multiple outstanding transactions.
        Best performance when max outstanding is design latency + 1.
        """
        return self.regblock_latency + 1

    @property
    def id_width(self) -> int:
        return 1  # Default ID width


class OBI_Cpuif_flattened(OBI_Cpuif):
    is_interface = False

    @property
    def package_name(self) -> Union[str, None]:
        return None

    @property
    def port_declaration(self) -> str:
        lines = [
            # OBI Request Channel (A)
            self.signal("req")   +  " : in std_logic;",
            self.signal("gnt")   +  " : out std_logic;",
            self.signal("addr")  + f" : in std_logic_vector({self.addr_width-1} downto 0);",
            self.signal("we")    +  " : in std_logic;"   ,
            self.signal("be")    + f" : in std_logic_vector({self.data_width//8-1} downto 0);",
            self.signal("wdata") + f" : in std_logic_vector({self.data_width-1} downto 0);",
            self.signal("aid")   +  " : in std_logic_vector(ID_WIDTH-1 downto 0);",

            # OBI Response Channel (R)
            self.signal("rvalid") +  " : out std_logic;",
            self.signal("rready") +  " : in std_logic;",
            self.signal("rdata")  + f" : out std_logic_vector({self.data_width-1} downto 0);",
            self.signal("err")    +  " : out std_logic;",
            self.signal("rid")    +  " : out std_logic_vector(ID_WIDTH-1 downto 0)",
        ]
        return "\n".join(lines)

    def signal(self, name: str) -> str:
        return "s_obi_" + name

    @property
    def parameters(self) -> List[str]:
        return ["ID_WIDTH : positive := 1"]
