{%- if cpuif.is_interface -%}
-- pragma translate_off
cpuif_generics: process begin
    assert_bad_addr_width: assert {{cpuif.signal("addr")}}'length >= {{ds.module_name.upper()}}_MIN_ADDR_WIDTH
        report "Interface address width of " & integer'image({{cpuif.signal("addr")}}'length) & " is too small. Shall be at least " & integer'image({{ds.module_name.upper()}}_MIN_ADDR_WIDTH) & " bits"
        severity failure;
    assert_bad_data_width: assert {{cpuif.signal("wdata")}}'length = {{ds.module_name.upper()}}_DATA_WIDTH
        report "Interface data width of " & integer'image({{cpuif.signal("wdata")}}'length) & " is incorrect. Shall be " & integer'image({{ds.module_name.upper()}}_DATA_WIDTH) & " bits"
        severity failure;
    wait;
end process;
-- pragma translate_on

{% endif -%}

-- Latch AID on accept to echo back the response
{%- macro obi_reset() %}
    is_active <= '0';
    gnt_q <= '0';
    rsp_pending <= '0';
    rsp_rdata_q <= (others => '0');
    rsp_err_q <= '0';
    rid_q <= (others => '0');

    cpuif_req <= '0';
    cpuif_req_is_wr <= '0';
    cpuif_addr <= (others => '0');
    cpuif_wr_data <= (others => '0');
    cpuif_wr_biten <= (others => '0');
{%- endmacro %}
process({{get_always_ff_event(cpuif.reset)}}) begin
    if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
        {{- obi_reset() | indent }}
    elsif rising_edge(clk) then
        if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
            {{- obi_reset() | indent(8) }}
        else
            -- defaults
            cpuif_req <= '0';
            gnt_q <= {{cpuif.signal("req")}} and not is_active;

            -- Accept new request when idle
            if not is_active then
                if {{cpuif.signal("req")}} then
                    is_active <= '1';
                    cpuif_req <= '1';
                    cpuif_req_is_wr <= {{cpuif.signal("we")}};
                    cpuif_addr <= ({{cpuif.addr_width-1}} downto {{clog2(cpuif.data_width_bytes)}} => {{cpuif.signal("addr")}}({{cpuif.addr_width-1}} downto {{clog2(cpuif.data_width_bytes)}}), others => '0');
                    cpuif_wr_data <= {{cpuif.signal("wdata")}};
                    rid_q <= {{cpuif.signal("aid")}};
                    for i in {{cpuif.signal("be")}}'RANGE loop
                        cpuif_wr_biten(i*8 + 7 downto i*8) <= (others => {{cpuif.signal("be")}}(i));
                    end loop;
                end if;
            end if;

            -- Capture response
            if is_active and (cpuif_rd_ack or cpuif_wr_ack) then
              rsp_pending <= '1';
              rsp_rdata_q <= cpuif_rd_data;
              rsp_err_q <= cpuif_rd_err or cpuif_wr_err;
              -- NOTE: Keep 'is_active' asserted until the external R handshake completes
            end if;

            -- Complete external R-channel handshake only if manager ready
            if rsp_pending and {{cpuif.signal("rvalid")}} and {{cpuif.signal("rready")}} then
              rsp_pending <= '0';
              is_active <= '0'; -- free to accept the next request
            end if;
        end if;
    end if;
end process;

-- R-channel outputs (held stable while rsp_pending=1)
{{cpuif.signal("rvalid")}} <= rsp_pending;
{{cpuif.signal("rdata")}} <= rsp_rdata_q;
{{cpuif.signal("err")}} <= rsp_err_q;
{{cpuif.signal("rid")}} <= rid_q;

-- A-channel grant (registered one-cycle pulse when we accept a request)
{{cpuif.signal("gnt")}} <= gnt_q;