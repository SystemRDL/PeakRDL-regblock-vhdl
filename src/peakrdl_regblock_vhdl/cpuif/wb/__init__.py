from typing import Union
from ..base import CpuifBase

class wb_Cpuif(CpuifBase):
    template_path = "wb_tmpl.vhd"
    is_interface = True

    @property
    def package_name(self) -> Union[str, None]:
        return "wb_intf_pkg"

    @property
    def port_declaration(self) -> str:
        return "\n".join([
            "wb_i : in wb_agent_in_intf(",
           f"    adr({self.addr_width-1} downto 0),",
           f"    idat({self.data_width-1} downto 0),",
           f"    sel({self.data_width_bytes-1} downto 0)",
            ");",
            "wb_o : out wb_agent_out_intf(",
           f"    odat({self.data_width-1} downto 0)",
            ")",
        ])

    @property
    def signal_declaration(self) -> str:
        return ""

    def signal(self, name:str) -> str:
        if name.lower() in ("we", "cyc", "stb"):
            return "wb_i." + name
        else:
            return "wb_o." + name


class wb_Cpuif_flattened(wb_Cpuif):
    is_interface = False

    @property
    def package_name(self) -> Union[str, None]:
        return None

    @property
    def port_declaration(self) -> str:
        lines = [
            self.signal("we")    +  "    : in std_logic;",
            self.signal("cyc")    +  "   : in std_logic;",
            self.signal("stb")    +  "   : in std_logic;",
            self.signal("sel")    + f"   : in std_logic_vector({self.data_width_bytes-1} downto 0);",
            self.signal("adr")    + f"   : in std_logic_vector({self.addr_width-1} downto 0);",
            self.signal("idat")    + f"  : in std_logic_vector({self.data_width-1} downto 0);",
            self.signal("odat")    + f"  : out std_logic_vector({self.data_width-1} downto 0);",
            self.signal("ack")    +  "   : out std_logic;",
            self.signal("err")    +  "   : out std_logic;",
            self.signal("stall")    +  " : out std_logic",
        ]
        return "\n".join(lines)

    def signal(self, name:str) -> str:
        return "wb_" + name
