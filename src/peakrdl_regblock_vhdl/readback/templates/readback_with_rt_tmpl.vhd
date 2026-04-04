-- readback stage 1
process(all)
    variable readback_data_var : readback_data_array_t;
begin
    readback_data_var := READBACK_DATA_ARRAY_ZEROS;
    {{readback_mux|indent}}
    readback_data_rt_c <= readback_data_var;
end process;

process({{get_always_ff_event(cpuif.reset)}}) begin
    if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
        readback_data_rt <= READBACK_DATA_ARRAY_ZEROS;
        readback_done_rt <= '0';
        readback_err_rt <= '0';
        readback_addr_rt <= (others => '0');
    elsif rising_edge(clk) then
        if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
            readback_data_rt <= READBACK_DATA_ARRAY_ZEROS;
            readback_done_rt <= '0';
            readback_err_rt <= '0';
            readback_addr_rt <= (others => '0');
        else
            readback_data_rt <= readback_data_rt_c;
            readback_err_rt <= decoded_err;
            {%- if ds.has_external_addressable %}
            readback_done_rt <= decoded_req and not decoded_req_is_wr and not decoded_req_is_external;
            {%- else %}
            readback_done_rt <= decoded_req and not decoded_req_is_wr;
            {%- endif %}
            readback_addr_rt <= rd_mux_addr;
        end if;
    end if;
end process;

{% if ds.has_external_block %}
process(all)
    variable readback_data_var : std_logic_vector({{cpuif.data_width-1}} downto 0);
    variable is_external_block_var : std_logic;
begin
    readback_data_var := (others => '0');
    is_external_block_var := '0';
    {{ext_block_readback_mux|indent}}
    readback_ext_block_data_rt_c <= readback_data_var;
    readback_is_ext_block_c <= is_external_block_var;
end process;

process({{get_always_ff_event(cpuif.reset)}}) begin
    if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
        readback_ext_block_data_rt <= (others => '0');
        readback_is_ext_block <= '0';
    elsif rising_edge(clk) then
        if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
            readback_ext_block_data_rt <= (others => '0');
            readback_is_ext_block <= '0';
        else
            readback_ext_block_data_rt <= readback_ext_block_data_rt_c;
            readback_is_ext_block <= readback_is_ext_block_c;
        end if;
    end if;
end process;
{% endif %}

-- readback stage 2
process(all)
begin
    {%- if ds.has_external_block %}
    if readback_is_ext_block then
        readback_data <= readback_ext_block_data_rt;
    else
        readback_data <= readback_data_rt(to_integer(readback_addr_rt({{ds.addr_width-1}} downto {{low_addr_width}})));
    end if;
    {%- else %}
    readback_data <= readback_data_rt(to_integer(readback_addr_rt({{ds.addr_width-1}} downto {{low_addr_width}})));
    {%- endif %}
    readback_done <= readback_done_rt;
    {%- if ds.err_if_bad_addr or ds.err_if_bad_rw %}
    readback_err <= readback_err_rt;
    {%- else %}
    readback_err <= '0';
    {%- endif %}
end process;
