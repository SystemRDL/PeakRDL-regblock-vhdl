{% extends "lib/tb_base.sv" %}

{% block seq %}
    {% sv_line_anchor %}
    ##1;
    cb.rst <= '0;
    cb.hwif_in.endpoint[0].interrupt.f_event.next <= 'h0;
    ##1;

    cpuif.assert_read('h0, 'h00);
    cpuif.assert_read('h8, 'h00);
    cpuif.assert_read('hC, 'h00);

    cb.hwif_in.endpoint[0].interrupt.f_event.next <= 'h1;
    @cb;
    cb.hwif_in.endpoint[0].interrupt.f_event.next <= 'h0;

    cpuif.assert_read('h0, 'h01);
    cpuif.assert_read('h8, 'h01);
    cpuif.assert_read('hC, 'h00);

    cpuif.write('h8, 'h1); // woclr

    cpuif.assert_read('h0, 'h00);
    cpuif.assert_read('h8, 'h00);
    cpuif.assert_read('hC, 'h00);

{% endblock %}
