from typing import Union
from ..base import CpuifBase
from ...utils import clog2

class Avalon_Cpuif(CpuifBase):
    template_path = "avalon_tmpl.vhd"

    @property
    def package_name(self) -> Union[str, None]:
        return "avalon_mm_intf_pkg"

    @property
    def port_declaration(self) -> str:
        return "\n".join([
            "avalon_i : in avalon_agent_in_intf(",
           f"    address({self.word_addr_width-1} downto 0),",
           f"    writedata({self.data_width-1} downto 0),",
           f"    byteenable({self.data_width_bytes-1} downto 0)",
            ");",
            "avalon_o : out avalon_agent_out_intf(",
           f"    readdata({self.data_width-1} downto 0)",
            ")",
        ])

    @property
    def signal_declaration(self) -> str:
        return ""

    def signal(self, name:str) -> str:
        if name.lower() in ("read", "write", "address", "writedata", "byteenable"):
            return "avalon_i." + name
        else:
            return "avalon_o." + name

    @property
    def word_addr_width(self) -> int:
        # Avalon agents use word addressing, therefore address width is reduced
        return self.addr_width - clog2(self.data_width_bytes)

class Avalon_Cpuif_flattened(Avalon_Cpuif):
    @property
    def port_declaration(self) -> str:
        lines = [
            self.signal("read")               +  " : in std_logic;",
            self.signal("write")              +  " : in std_logic;",
            self.signal("waitrequest")        +  " : out std_logic;",
            self.signal("address")            + f" : in std_logic_vector({self.word_addr_width-1} downto 0);",
            self.signal("writedata")          + f" : in std_logic_vector({self.data_width-1} downto 0);",
            self.signal("byteenable")         + f" : in std_logic_vector({self.data_width_bytes-1} downto 0);",
            self.signal("readdatavalid")      +  " : out std_logic;",
            self.signal("writeresponsevalid") +  " : out std_logic;",
            self.signal("readdata")           + f" : out std_logic_vector({self.data_width-1} downto 0);",
            self.signal("response")           +  " : out std_logic_vector(1 downto 0)",
        ]
        return "\n".join(lines)

    def signal(self, name:str) -> str:
        return "avalon_" + name
