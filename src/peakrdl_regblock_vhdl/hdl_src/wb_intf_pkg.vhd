library ieee;
context ieee.ieee_std_context;

package wb_intf_pkg is

    type wb_agent_in_intf is record
        we : std_logic;
        stb : std_logic;
        cyc : std_logic;
        adr : std_logic_vector;
        idat : std_logic_vector;
        sel : std_logic_vector;
    end record wb_agent_in_intf;

    type wb_agent_out_intf is record
        ack : std_logic;
        err : std_logic;
        stall : std_logic;
        odat : std_logic_vector;
    end record wb_agent_out_intf;

end package wb_intf_pkg;
