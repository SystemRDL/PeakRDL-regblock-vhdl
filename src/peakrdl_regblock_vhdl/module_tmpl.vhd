-- Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
--  https://github.com/SystemRDL/PeakRDL-regblock
library ieee;
context ieee.ieee_std_context;

use work.{{ds.module_name}}_pkg.all;
{%- if cpuif.package_name %}
use work.{{cpuif.package_name}}.all;
{%- endif %}
use work.reg_utils.all;

entity {{ds.module_name}} is
    {%- if cpuif.parameters %}
    generic (
        {{";\n        ".join(cpuif.parameters)}}
    );
    {%- endif %}
    port (
        clk : in std_logic;
        {{default_resetsignal_name}} : in std_logic;

        {%- for signal in ds.out_of_hier_signals.values() %}
        {%- if signal.width == 1 %}
        {{kwf(signal.inst_name)}} : in std_logic;
        {%- else %}
        {{kwf(signal.inst_name)}} : in std_logic_vector({{signal.width-1}} downto 0);
        {%- endif %}
        {%- endfor %}

        {%- if ds.has_paritycheck %}
        parity_error : out std_logic;
        {%- endif %}

        {{cpuif.port_declaration|indent(8)}}
        {%- if hwif.has_input_struct or hwif.has_output_struct %};{% endif %}

        {{hwif.port_declaration|indent(8)}}
    );
end entity {{ds.module_name}};

architecture rtl of {{ds.module_name}} is
    ----------------------------------------------------------------------------
    -- CPU Bus interface signals
    ----------------------------------------------------------------------------
    signal cpuif_req : std_logic;
    signal cpuif_req_is_wr : std_logic;
    signal cpuif_addr : std_logic_vector({{cpuif.addr_width-1}} downto 0);
    signal cpuif_wr_data : std_logic_vector({{cpuif.data_width-1}} downto 0);
    signal cpuif_wr_biten : std_logic_vector({{cpuif.data_width-1}} downto 0);
    signal cpuif_req_stall_wr : std_logic;
    signal cpuif_req_stall_rd : std_logic;

    signal cpuif_rd_ack : std_logic;
    signal cpuif_rd_err : std_logic;
    signal cpuif_rd_data : std_logic_vector({{cpuif.data_width-1}} downto 0);

    signal cpuif_wr_ack : std_logic;
    signal cpuif_wr_err : std_logic;

    signal cpuif_req_masked : std_logic;

    {{cpuif.signal_declaration | indent}}

    {%- if ds.has_external_addressable %}
    signal external_req : std_logic;
    signal external_pending : std_logic;
    signal external_wr_ack : std_logic;
    signal external_rd_ack : std_logic;
    {%- endif %}

    {%- if ds.min_read_latency > ds.min_write_latency %}
    signal cpuif_req_stall_sr : std_logic_vector({{ds.min_read_latency - ds.min_write_latency - 1}} downto 0);
    {%- elif ds.min_read_latency < ds.min_write_latency %}
    signal cpuif_req_stall_sr : std_logic_vector({{ds.min_write_latency - ds.min_read_latency - 1}} downto 0);
    {%- endif %}

    ----------------------------------------------------------------------------
    -- Address Decode Signals
    ----------------------------------------------------------------------------
    {{address_decode.get_strobe_struct()|indent}}
    signal decoded_reg_strb : decoded_reg_strb_t;

    {%- if ds.has_external_addressable %}
    signal decoded_strb_is_external : std_logic;
    {% endif %}
    {%- if ds.has_external_block %}
    signal decoded_addr : std_logic_vector({{cpuif.addr_width-1}} downto 0);
    {% endif %}
    signal decoded_req : std_logic;
    signal decoded_req_is_wr : std_logic;
    signal decoded_wr_data : std_logic_vector({{cpuif.data_width-1}} downto 0);
    signal decoded_wr_biten : std_logic_vector({{cpuif.data_width-1}} downto 0);

    {%- if ds.has_writable_msb0_fields %}
    signal decoded_wr_data_bswap : std_logic_vector({{cpuif.data_width-1}} downto 0);
    signal decoded_wr_biten_bswap : std_logic_vector({{cpuif.data_width-1}} downto 0);
    {%- endif %}

    ----------------------------------------------------------------------------
    -- Field Logic Signals
    ----------------------------------------------------------------------------
    {{field_logic.get_combo_struct()|indent}}

    {{field_logic.get_storage_struct()|indent}}

{%- if ds.has_buffered_write_regs %}

    ----------------------------------------------------------------------------
    -- Write Buffer Signals
    ----------------------------------------------------------------------------
    {{write_buffering.get_storage_struct()|indent}}
{%- endif %}

{%- if ds.has_buffered_read_regs %}

    ----------------------------------------------------------------------------
    -- Read Buffer Signals
    ----------------------------------------------------------------------------
    {{read_buffering.get_storage_struct()|indent}}
{%- endif %}

    ----------------------------------------------------------------------------
    -- Readback Signals
    ----------------------------------------------------------------------------
    {%- if ds.has_external_addressable %}
    signal readback_external_rd_ack_c : std_logic;
    signal readback_external_rd_ack : std_logic;
    {%- endif %}
    signal readback_err : std_logic;
    signal readback_done : std_logic;
    signal readback_data : std_logic_vector({{cpuif.data_width-1}} downto 0);
    {{ readback.signal_declaration | indent }}

begin

    ----------------------------------------------------------------------------
    -- CPU Bus interface
    ----------------------------------------------------------------------------
    {{cpuif.get_implementation() | indent}}

{%- if ds.has_external_addressable %}
    process({{get_always_ff_event(cpuif.reset)}}) begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            external_pending <= '0';
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                external_pending <= '0';
            else
                if external_req and not external_wr_ack and not external_rd_ack then
                    external_pending <= '1';
                elsif external_wr_ack or external_rd_ack then
                    external_pending <= '0';
                end if;
                assert not external_wr_ack or (external_pending or external_req)
                    report "An external wr_ack strobe was asserted when no external request was active";
                assert not external_rd_ack or (external_pending or external_req)
                    report "An external rd_ack strobe was asserted when no external request was active";
            end if;
        end if;
    end process;
{%- endif %}
{% if ds.min_read_latency == ds.min_write_latency %}
    -- Read & write latencies are balanced. Stalls not required
    {%- if ds.has_external_addressable %}
    -- except if external
    cpuif_req_stall_rd <= external_pending;
    cpuif_req_stall_wr <= external_pending;
    {%- else %}
    cpuif_req_stall_rd <= '0';
    cpuif_req_stall_wr <= '0';
    {%- endif %}
{%- elif ds.min_read_latency > ds.min_write_latency %}
    -- Read latency > write latency. May need to delay next write that follows a read
    process({{get_always_ff_event(cpuif.reset)}}) begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            cpuif_req_stall_sr <= (others => '0');
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                cpuif_req_stall_sr <= (others => '0');
            elsif cpuif_req and not cpuif_req_is_wr then
                cpuif_req_stall_sr <= (others => '0');
            else
                cpuif_req_stall_sr <= "0" & cpuif_req_stall_sr(cpuif_req_stall_sr'high downto 1);
            end if;
        end if;
    end process;
    {%- if ds.has_external_addressable %}
    cpuif_req_stall_rd <= external_pending;
    cpuif_req_stall_wr <= cpuif_req_stall_sr(0) or external_pending;
    {%- else %}
    cpuif_req_stall_rd <= '0';
    cpuif_req_stall_wr <= cpuif_req_stall_sr(0);
    {%- endif %}
{%- else %}
    -- Write latency > read latency. May need to delay next read that follows a write
    process({{get_always_ff_event(cpuif.reset)}}) begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            cpuif_req_stall_sr <= '0';
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                cpuif_req_stall_sr <= '0';
            elsif cpuif_req and cpuif_req_is_wr then
                cpuif_req_stall_sr <= '1';
            else
                cpuif_req_stall_sr <= "0" & cpuif_req_stall_sr(cpuif_req_stall_sr'high downto 1);
            end if;
        end if;
    end process;
    {%- if ds.has_external_addressable %}
    cpuif_req_stall_rd <= cpuif_req_stall_sr(0) or external_pending;
    cpuif_req_stall_wr <= external_pending;
    {%- else %}
    cpuif_req_stall_rd <= cpuif_req_stall_sr(0);
    cpuif_req_stall_wr <= '0';
    {%- endif %}
{%- endif %}
    cpuif_req_masked <= cpuif_req
                        and not (not cpuif_req_is_wr and cpuif_req_stall_rd)
                        and not (cpuif_req_is_wr and cpuif_req_stall_wr);

    ----------------------------------------------------------------------------
    -- Address Decode
    ----------------------------------------------------------------------------
    process(all)
        -- overload "=" in this scope to avoid lots of type casts
        function "="(L: std_logic_vector; R: integer) return std_logic is
            variable result : std_logic;
        begin
            result := '1' when unsigned(L) = R else '0';
            return result;
        end;
        {%- if ds.has_external_addressable %}
        variable is_external: std_logic;
        {%- endif %}
    begin
    {%- if ds.has_external_addressable %}
        is_external := '0';
    {%- endif %}
        {{address_decode.get_implementation()|indent(8)}}
    {%- if ds.has_external_addressable %}
        decoded_strb_is_external <= is_external;
        external_req <= is_external;
    {%- endif %}
    end process;

    -- Pass down signals to next stage
    process(all) begin
    {%- if ds.has_external_block %}
        decoded_addr <= cpuif_addr;
    {%- endif %}
        decoded_req <= cpuif_req_masked;
        decoded_req_is_wr <= cpuif_req_is_wr;
        decoded_wr_data <= cpuif_wr_data;
        decoded_wr_biten <= cpuif_wr_biten;
    {%- if ds.has_writable_msb0_fields %}
        -- bitswap for use by fields with msb0 ordering
        decoded_wr_data_bswap <= bitswap(decoded_wr_data);
        decoded_wr_biten_bswap <= bitswap(decoded_wr_biten);
    {%- endif %}
    end process;

{%- if ds.has_buffered_write_regs %}

    ----------------------------------------------------------------------------
    -- Write double-buffers
    ----------------------------------------------------------------------------

    {{write_buffering.get_implementation()|indent}}
{%- endif %}

    ----------------------------------------------------------------------------
    -- Field logic
    ----------------------------------------------------------------------------
    {{field_logic.get_implementation()|indent}}

{%- if ds.has_paritycheck %}

    ----------------------------------------------------------------------------
    -- Parity Error
    ----------------------------------------------------------------------------
    process({{get_always_ff_event(cpuif.reset)}})
        variable err: std_logic;
    begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            parity_error <= '0';
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                parity_error <= '0';
            else
                err := '0';
                {{parity.get_implementation()|indent(12)}}
                parity_error <= err;
            end if;
        end if;
    end process;
{%- endif %}

{%- if ds.has_buffered_read_regs %}

    ----------------------------------------------------------------------------
    -- Read double-buffers
    ----------------------------------------------------------------------------
    {{read_buffering.get_implementation()|indent}}
{%- endif %}

    ----------------------------------------------------------------------------
    -- Write response
    ----------------------------------------------------------------------------
{%- if ds.has_external_addressable %}
    process(all)
        variable wr_ack: std_logic;
    begin
        wr_ack := '0';
        {{ext_write_acks.get_implementation()|indent(8)}}
        external_wr_ack <= wr_ack;
    end process;
    cpuif_wr_ack <= external_wr_ack or (decoded_req and decoded_req_is_wr and not decoded_strb_is_external);
{%- else %}
    cpuif_wr_ack <= decoded_req and decoded_req_is_wr;
{%- endif %}
    -- Writes are always granted with no error response
    cpuif_wr_err <= '0';

    ----------------------------------------------------------------------------
    -- Readback
    ----------------------------------------------------------------------------
{%- if ds.has_external_addressable %}
    process(all)
        variable rd_ack: std_logic;
    begin
        rd_ack := '0';
        {{ext_read_acks.get_implementation()|indent(8)}}
        readback_external_rd_ack_c <= rd_ack;
    end process;

    {%- if ds.retime_read_fanin %}
    process({{get_always_ff_event(cpuif.reset)}}) begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            readback_external_rd_ack <= '0';
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                readback_external_rd_ack <= '0';
            else
                readback_external_rd_ack <= readback_external_rd_ack_c;
            end if;
        end if;
    end process;

    {%- else %}

    readback_external_rd_ack <= readback_external_rd_ack_c;
    {%- endif %}
{%- endif %}

{%- macro readback_retime_reset() %}
        cpuif_rd_ack <= '0';
        cpuif_rd_data <= (others => '0');
        cpuif_rd_err <= '0';
        {%- if ds.has_external_addressable %}
        external_rd_ack <= '0';
        {%- endif %}
{%- endmacro %}
{{readback.get_implementation()|indent}}
{% if ds.retime_read_response %}
    process({{get_always_ff_event(cpuif.reset)}}) begin
        if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
            {{- readback_retime_reset() }}
        elsif rising_edge(clk) then
            if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
                {{- readback_retime_reset() | indent }}
            else
            {%- if ds.has_external_addressable %}
                external_rd_ack <= readback_external_rd_ack;
                cpuif_rd_ack <= readback_done or readback_external_rd_ack;
            {%- else %}
                cpuif_rd_ack <= readback_done;
            {%- endif %}
                cpuif_rd_data <= readback_data;
                cpuif_rd_err <= readback_err;
            end if;
        end if;
    end process;
{% else %}
    {%- if ds.has_external_addressable %}
    external_rd_ack <= readback_external_rd_ack;
    cpuif_rd_ack <= readback_done or readback_external_rd_ack;
    {%- else %}
    cpuif_rd_ack <= readback_done;
    {%- endif %}
    cpuif_rd_data <= readback_data;
    cpuif_rd_err <= readback_err;
{%- endif %}
end architecture rtl;
{# (eof newline anchor) #}
