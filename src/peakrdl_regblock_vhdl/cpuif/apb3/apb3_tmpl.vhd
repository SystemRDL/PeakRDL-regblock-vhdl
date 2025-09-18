{%- if cpuif.is_interface -%}
-- pragma translate_off
cpuif_generics: process begin
    assert_bad_addr_width: assert {{cpuif.signal("paddr")}}'length >= {{ds.module_name.upper()}}_MIN_ADDR_WIDTH
        report "Interface address width of " & integer'image({{cpuif.signal("paddr")}}'length) & " is too small. Shall be at least " & integer'image({{ds.module_name.upper()}}_MIN_ADDR_WIDTH) & " bits"
        severity failure;
    assert_bad_data_width: assert {{cpuif.signal("pwdata")}}'length = {{ds.module_name.upper()}}_DATA_WIDTH
        report "Interface data width of " & integer'image({{cpuif.signal("pwdata")}}'length) & " is incorrect. Shall be " & integer'image({{ds.module_name.upper()}}_DATA_WIDTH) & " bits"
        severity failure;
    wait;
end process;
-- pragma translate_on
{% endif %}

-- Request
{%- macro apb3_reset() %}
    apb_is_active <= '0';
    cpuif_req <= '0';
    cpuif_req_is_wr <= '0';
    cpuif_addr <= (others => '0');
    cpuif_wr_data <= (others => '0');
{%- endmacro %}
process({{get_always_ff_event(cpuif.reset)}}) begin
    if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
        {{- apb3_reset() | indent }}
    elsif rising_edge(clk) then
        if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
            {{- apb3_reset() | indent(8) }}
        else
            if not apb_is_active then
                if {{cpuif.signal("psel")}} then
                    apb_is_active <= '1';
                    cpuif_req <= '1';
                    cpuif_req_is_wr <= {{cpuif.signal("pwrite")}};
                    {%- if cpuif.data_width_bytes == 1 %}
                    cpuif_addr <= {{cpuif.signal("paddr")}}({{cpuif.addr_width-1}} downto 0);
                    {%- else %}
                    cpuif_addr <= ({{cpuif.addr_width-1}} downto {{clog2(cpuif.data_width_bytes)}} => {{cpuif.signal("paddr")}}({{cpuif.addr_width-1}} downto {{clog2(cpuif.data_width_bytes)}}), others => '0');
                    {%- endif %}
                    cpuif_wr_data <= {{cpuif.signal("pwdata")}};
                end if;
            else
                cpuif_req <= '0';
                if cpuif_rd_ack or cpuif_wr_ack then
                    apb_is_active <= '0';
                end if;
            end if;
        end if;
    end if;
end process;
cpuif_wr_biten <= (others => '1');

-- Response
{{cpuif.signal("pready")}} <= cpuif_rd_ack or cpuif_wr_ack;
{{cpuif.signal("prdata")}} <= cpuif_rd_data;
{{cpuif.signal("pslverr")}} <= cpuif_rd_err or cpuif_wr_err;
