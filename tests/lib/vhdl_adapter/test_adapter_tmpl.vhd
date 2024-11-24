library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

{%- macro sig_type(width, is_vec=False) %}
{%- if width == 1 and not is_vec -%}
std_logic
{%- else -%}
std_logic_vector({{width-1}} downto 0)
{%- endif %}
{%- endmacro %}

entity regblock_adapter_vhdl is
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

        {%- for cpuif_sig, is_vec, width in cpuif_signals_in %}
        {{ kwf(sv_cpuif.signal(cpuif_sig)) }} : in {{ sig_type(width, is_vec) }};
        {%- endfor %}
        {%- for cpuif_sig, is_vec, width in cpuif_signals_out %}
        {{ kwf(sv_cpuif.signal(cpuif_sig)) }} : out {{ sig_type(width, is_vec) }}
        {%- if not loop.last %};{% endif -%}
        {%- endfor %}
        {%- if hwif.has_input_struct or hwif.has_output_struct %};{% endif %}

        {%- for hwif_sig, width in hwif_signals %}
        {%- if hwif_sig.startswith("hwif_in") %}
        \{{ hwif_sig }}\ : in {{ sig_type(width) }}
        {%- else %}
        \{{ hwif_sig }}\ : out {{ sig_type(width) }}
        {%- endif %}
        {%- if not loop.last %};{% endif -%}
        {%- endfor %}
    );
end entity regblock_adapter_vhdl;

architecture rtl of regblock_adapter_vhdl is

begin

    dut: entity work.vhdl_regblock
        {%- if vhdl_cpuif.parameters %}
        generic map (
            {%- for param in vhdl_cpuif.parameters %}
            {{param}} => {{param}},
            {%- endfor %}
        )
        {%- endif %}
        port map (
            clk => clk,
            {{default_resetsignal_name}} => {{default_resetsignal_name}},

            {%- for signal in ds.out_of_hier_signals.values() %}
            {{kwf(signal.inst_name)}} => {{kwf(signal.inst_name)}},
            {%- endfor %}

            {%- if ds.has_paritycheck %}
            parity_error => parity_error,
            {%- endif %}

            {%- for cpuif_sig, _, _ in cpuif_signals_in %}
            {{ vhdl_cpuif.signal(cpuif_sig) }} => {{ kwf(sv_cpuif.signal(cpuif_sig)) }},
            {%- endfor %}
            {%- for cpuif_sig, _, _ in cpuif_signals_out %}
            {{ vhdl_cpuif.signal(cpuif_sig) }} => {{ kwf(sv_cpuif.signal(cpuif_sig)) }}
            {%-   if not loop.last %},{% endif -%}
            {%- endfor %}
            {%- if hwif.has_input_struct or hwif.has_output_struct %},{% endif %}

            {%- for hwif_sig, _ in hwif_signals %}
            {{ hwif_sv_to_vhdl(hwif_sig) }} => \{{ hwif_sig }}\
            {%-   if not loop.last %},{% endif -%}
            {%- endfor %}
        );

end architecture;