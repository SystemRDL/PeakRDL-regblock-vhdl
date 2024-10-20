-- Generated by PeakRDL-regblock - A free and open-source VHDL generator
--  https://github.com/SystemRDL/PeakRDL-regblock
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package {{ds.package_name}} is
    constant {{ds.module_name.upper()}}_DATA_WIDTH : integer := {{ds.cpuif_data_width}};
    constant {{ds.module_name.upper()}}_MIN_ADDR_WIDTH : integer := {{ds.addr_width}};

    {{hwif.get_package_contents()|indent}}
end package;
{# (eof newline anchor) #}
