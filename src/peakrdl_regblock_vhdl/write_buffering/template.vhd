{%- macro wbuf_reset() %}
        {{wbuf_prefix}}.pending <= '0';
        {{wbuf_prefix}}.data <= (others => '0');
        {{wbuf_prefix}}.biten <= (others => '0');
        {%- if is_own_trigger %}
        {{wbuf_prefix}}.trigger_q <= '0';
        {%- endif %}
{%- endmacro -%}

process({{get_always_ff_event(cpuif.reset)}}) begin
    if {{get_resetsignal(cpuif.reset, asynch=True)}} then -- async reset
        {{- wbuf_reset() }}
    elsif rising_edge(clk) then
        if {{get_resetsignal(cpuif.reset, asynch=False)}} then -- sync reset
            {{- wbuf_reset() | indent }}
        else
            if {{wbuf.get_trigger(node)}} then
                {{wbuf_prefix}}.pending <= '0';
                {{wbuf_prefix}}.data <= (others => '0');
                {{wbuf_prefix}}.biten <= (others => '0');
            end if;
            {%- for segment in segments %}
            if {{segment.strobe}} and decoded_req_is_wr then
                {{wbuf_prefix}}.pending <= '1';
                {%- if node.inst.is_msb0_order %}
                {{wbuf_prefix}}.data{{segment.bslice}} <= ({{wbuf_prefix}}.data{{segment.bslice}} and not decoded_wr_biten_bswap) or (decoded_wr_data_bswap and decoded_wr_biten_bswap);
                {{wbuf_prefix}}.biten{{segment.bslice}} <= {{wbuf_prefix}}.biten{{segment.bslice}} or decoded_wr_biten_bswap;
                {%- else %}
                {{wbuf_prefix}}.data{{segment.bslice}} <= ({{wbuf_prefix}}.data{{segment.bslice}} and not decoded_wr_biten) or (decoded_wr_data and decoded_wr_biten);
                {{wbuf_prefix}}.biten{{segment.bslice}} <= {{wbuf_prefix}}.biten{{segment.bslice}} or decoded_wr_biten;
                {%- endif %}
            end if;
            {%- endfor %}
            {%- if is_own_trigger %}
            {{wbuf_prefix}}.trigger_q <= {{wbuf.get_raw_trigger(node)}};
            {%- endif %}
        end if;
    end if;
end process;