from typing import Union
from ..base import CpuifBase

class Wishbone_Cpuif(CpuifBase):
    template_path = "wishbone_tmpl.vhd"
    is_interface = True

    @property
    def package_name(self) -> Union[str, None]:
        return "wishbone_intf_pkg"

    @property
    def port_declaration(self) -> str:
        return "\n".join([
            "wb_i : in wb_agent_in_intf(",
           f"    adr({self.addr_width-1} downto 0),",
           f"    odat({self.data_width-1} downto 0),",
           f"    sel({self.data_width_bytes-1} downto 0)",
            ");",
            "wb_o : out wb_agent_out_intf(",
           f"    idat({self.data_width-1} downto 0)",
            ")",
        ])

    @property
    def signal_declaration(self) -> str:
        return ""

    def signal(self, name: str) -> str:
        if name.lower() in ("ack", "err", "stall", "idat"):
            return "wb_o." + name
        else:
            return "wb_i." + name


class Wishbone_Cpuif_flattened(Wishbone_Cpuif):
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
            self.signal("odat")    + f"  : in std_logic_vector({self.data_width-1} downto 0);",
            self.signal("idat")    + f"  : out std_logic_vector({self.data_width-1} downto 0);",
            self.signal("ack")    +  "   : out std_logic;",
            self.signal("err")    +  "   : out std_logic;",
            self.signal("stall")    +  " : out std_logic",
        ]
        return "\n".join(lines)

    def signal(self, name: str) -> str:
        return "wb_" + name
