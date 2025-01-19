library ieee;
context ieee.ieee_std_context;

package avalon_mm_intf_pkg is

    type avalon_agent_in_intf is record
        -- Command
        read : std_logic;
        write : std_logic;
        address : std_logic_vector;
        writedata : std_logic_vector;
        byteenable : std_logic_vector;
    end record avalon_agent_in_intf;

    type avalon_agent_out_intf is record
        -- Command
        waitrequest : std_logic;
        -- Response
        readdatavalid : std_logic;
        writeresponsevalid : std_logic;
        readdata : std_logic_vector;
        response : std_logic_vector(1 downto 0);
    end record avalon_agent_out_intf;

end package avalon_mm_intf_pkg;

-- package body avalon_mm_intf_pkg is
-- end package body avalon_mm_intf_pkg;
