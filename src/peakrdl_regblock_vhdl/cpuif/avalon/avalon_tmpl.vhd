-- Request
process(all) begin
    cpuif_req <= {{cpuif.signal("read")}} or {{cpuif.signal("write")}};
    cpuif_req_is_wr <= {{cpuif.signal("write")}};
    {%- if cpuif.data_width_bytes == 1 %}
    cpuif_addr <= {{cpuif.signal("address")}};
    {%- else %}
    cpuif_addr <= ({{cpuif.addr_width-1}} downto {{clog2(cpuif.data_width_bytes)}} => {{cpuif.signal("address")}}, others => '0');
    {%- endif %}
    cpuif_wr_data <= {{cpuif.signal("writedata")}};
    for i in 0 to {{cpuif.data_width_bytes-1}} loop
        cpuif_wr_biten((i+1)*8-1 downto i*8) <= (others => {{cpuif.signal("byteenable")}}(i));
    end loop;
    {{cpuif.signal("waitrequest")}} <= (cpuif_req_stall_rd and {{cpuif.signal("read")}}) or (cpuif_req_stall_wr and {{cpuif.signal("write")}});
end process;

-- Response
process(all) begin
    {{cpuif.signal("readdatavalid")}} <= cpuif_rd_ack;
    {{cpuif.signal("writeresponsevalid")}} <= cpuif_wr_ack;
    {{cpuif.signal("readdata")}} <= cpuif_rd_data;
    if cpuif_rd_err or cpuif_wr_err then
        -- SLVERR
        {{cpuif.signal("response")}} <= "10";
    else
        -- OK
        {{cpuif.signal("response")}} <= "00";
    end if;
end process;
