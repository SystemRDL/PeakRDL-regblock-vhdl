readback_done <= decoded_req and not decoded_req_is_wr;
readback_data <= (others => '0');
{%- if ds.err_if_bad_addr or ds.err_if_bad_rw %}
readback_err <= decoded_err;
{%- else %}
readback_err <= '0';
{%- endif %}
