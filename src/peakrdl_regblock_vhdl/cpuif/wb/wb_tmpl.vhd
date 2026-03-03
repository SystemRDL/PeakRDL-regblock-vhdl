{%- if cpuif.is_interface -%}
-- pragma translate_off
cpuif_generics: process begin
    assert_bad_addr_width: assert {{cpuif.signal("adr")}}'length >= {{cpuif.addr_width}}
        report "Interface address width of " & integer'image({{cpuif.signal("adr")}}'length) & " is too small. Shall be at least " & integer'image({{cpuif.addr_width}}) & " bits"
        severity failure;
    assert_bad_data_width: assert {{cpuif.signal("idat")}}'length = {{ds.module_name.upper()}}_DATA_WIDTH
        report "Interface data width of " & integer'image({{cpuif.signal("idat")}}'length) & " is incorrect. Shall be " & integer'image({{ds.module_name.upper()}}_DATA_WIDTH) & " bits"
        severity failure;
    wait;
end process;
-- pragma translate_on
{% endif %}

-- Request
process(all) begin
    cpuif_req <= {{cpuif.signal("stb")}};
    cpuif_req_is_wr <= {{cpuif.signal("we")}};
    cpuif_addr <= {{cpuif.signal("adr")}};
    cpuif_wr_data <= {{cpuif.signal("idat")}};
    for i in 0 to {{cpuif.data_width_bytes-1}} loop
        cpuif_wr_biten((i+1)*8-1 downto i*8) <= (others => {{cpuif.signal("sel")}}(i));
    end loop;
    {{cpuif.signal("stall")}} <=  {{cpuif.signal("stb")}} or (cpuif_req_stall_wr or cpuif_req_stall_rd);
end process;

-- Response
process(all) begin
    {{cpuif.signal("ack")}} <= cpuif_rd_ack or cpuif_wr_ack;
    {{cpuif.signal("odat")}} <= cpuif_rd_data;
    {{cpuif.signal("err")}} <= cpuif_rd_err or cpuif_wr_err;
end process;
