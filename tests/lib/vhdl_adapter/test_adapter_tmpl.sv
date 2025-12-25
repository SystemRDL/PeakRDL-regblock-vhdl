{%- macro escape(identifier) -%}
{%- if "." in identifier %}\{{identifier}} {% else %}{{identifier}}{% endif -%}
{%- endmacro -%}

module regblock_adapter_sv
    {%- if sv_cpuif.parameters %} #(
        {{",\n        ".join(sv_cpuif.parameters)}}
    ) {%- endif %} (
        input wire clk,
        input wire {{default_resetsignal_name}},

        {%- for signal in ds.out_of_hier_signals.values() %}
        {%- if signal.width == 1 %}
        input wire {{kwf(signal.inst_name)}},
        {%- else %}
        input wire [{{signal.width-1}}:0] {{kwf(signal.inst_name)}},
        {%- endif %}
        {%- endfor %}

        {%- if ds.has_paritycheck %}

        output logic parity_error,
        {%- endif %}

        {{sv_cpuif.port_declaration|indent(8)}}
        {%- if hwif.has_input_struct or hwif.has_output_struct %},{% endif %}

        {{hwif.port_declaration|indent(8)}}
    );

    regblock_adapter_vhdl
    {%- if sv_cpuif.parameters %} #(
        {%- for param in sv_cpuif.parameters %}
        {%- set param_name = param.removeprefix("parameter").split("=")[0].strip() %}
        .{{param_name}}({{param_name}}){% if not loop.last %},{% endif %}
        {%- endfor %}
    )
    {%- endif %} adpt_vhdl (
        .clk(clk),
        .{{default_resetsignal_name}}({{default_resetsignal_name}}),

        {%- for signal in ds.out_of_hier_signals.values() %}
        .{{kwf(signal.inst_name)}}({{kwf(signal.inst_name)}}),
        {%- endfor %}

        {%- if ds.has_paritycheck %}
        .parity_error(parity_error),
        {%- endif %}

        {%- for cpuif_sig, _, _ in cpuif_signals %}
        .{{ escape(sv_cpuif.signal(cpuif_sig)) }}({{ sv_cpuif.signal(cpuif_sig) }})
        {%- if not loop.last %},{% endif -%}
        {%- endfor %}
        {%- if hwif.has_input_struct or hwif.has_output_struct %},{% endif %}

        {%- for hwif_sig, _ in hwif_signals %}
        .{{ escape(hwif_sig) }}({{ hwif_sig }})
        {%- if not loop.last %},{% endif -%}
        {%- endfor %}
    );

endmodule