{% if retime -%}


{%- macro ext_block_reset() %}
    {{prefix}}.req <= '0';
    {%- if addr_width == 0 %}
    {{prefix}}.addr <= '0';
    {%- elif addr_width == 1 %}
    {{prefix}}.addr <= '0';
    {%- else %}
    {{prefix}}.addr <= (others => '0');
    {%- endif %}
    {{prefix}}.req_is_wr <= '0';
    {{prefix}}.wr_data <= (others => '0');
    {{prefix}}.wr_biten <= (others => '0');
{%- endmacro %}
process({{get_always_ff_event(resetsignal)}}) begin
    if {{get_resetsignal(resetsignal, asynch=True)}} then -- async reset
        {{- ext_block_reset() | indent }}
    elsif rising_edge(clk) then
        if {{get_resetsignal(resetsignal, asynch=False)}} then -- sync reset
            {{- ext_block_reset() | indent(8) }}
        else
            {{prefix}}.req <= {{strb}};
            {%- if addr_width == 0 %}
            {{prefix}}.addr <= decoded_addr(0);
            {%- elif addr_width == 1 %}
            {{prefix}}.addr <= decoded_addr(0);
            {%- else %}
            {{prefix}}.addr <= decoded_addr({{addr_width-1}} downto 0);
            {%- endif %}
            {{prefix}}.req_is_wr <= decoded_req_is_wr;
            {{prefix}}.wr_data <= decoded_wr_data;
            {{prefix}}.wr_biten <= decoded_wr_biten;
        end if;
    end if;
end process;


{%- else -%}


{{prefix}}.req <= {{strb}};
{%- if addr_width == 0 %}
{{prefix}}.addr <= decoded_addr(0);
{%- elif addr_width == 1 %}
{{prefix}}.addr <= decoded_addr(0);
{%- else %}
{{prefix}}.addr <= decoded_addr({{addr_width-1}} downto 0);
{%- endif %}
{{prefix}}.req_is_wr <= decoded_req_is_wr;
{{prefix}}.wr_data <= decoded_wr_data;
{{prefix}}.wr_biten <= decoded_wr_biten;


{%- endif %}
