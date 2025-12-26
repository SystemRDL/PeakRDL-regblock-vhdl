library ieee;
context ieee.ieee_std_context;

package obi_intf_pkg is

    type obi_subordinate_in_intf is record
        req    : std_logic;
        addr   : std_logic_vector;
        we     : std_logic;
        be     : std_logic_vector;
        wdata  : std_logic_vector;
        aid    : std_logic_vector;

        rready : std_logic;
    end record obi_subordinate_in_intf;

    type obi_subordinate_out_intf is record
        gnt    : std_logic;

        rvalid : std_logic;
        rdata  : std_logic_vector;
        err    : std_logic;
        rid    : std_logic_vector;
    end record obi_subordinate_out_intf;

end package obi_intf_pkg;

-- package body obi_intf_pkg is
-- end package body obi_intf_pkg;
