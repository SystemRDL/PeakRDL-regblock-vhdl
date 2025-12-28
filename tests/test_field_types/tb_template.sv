{% extends "lib/tb_base.sv" %}

{% block seq %}
    {% sv_line_anchor %}
    cb.hwif_in.r3.f1.wel <= 1;
    cb.hwif_in.r3.f2.wel <= 1;
    ##1;
    cb.rst <= '0;
    ##1;

    // r1 - sw=rw; hw=rw; we; // Storage element
    cpuif.assert_read('h0, 10);
    assert(cb.hwif_out.r1.f1.value == 10);
    assert(cb.hwif_out.r1.f2.value == 0);

    cpuif.write('h0, 11 + (1 << 7));
    cpuif.assert_read('h0, 11 + (1 << 7));
    assert(cb.hwif_out.r1.f1.value == 11);
    assert(cb.hwif_out.r1.f2.value == 1);

    cb.hwif_in.r1.f1.next <= 9;
    cb.hwif_in.r1.f2.next <= 0;
    cpuif.assert_read('h0, 11 + (1 << 7));
    assert(cb.hwif_out.r1.f1.value == 11);
    assert(cb.hwif_out.r1.f2.value == 1);
    cb.hwif_in.r1.f1.next <= 12;
    cb.hwif_in.r1.f2.next <= 0;
    cb.hwif_in.r1.f1.we <= 1;
    cb.hwif_in.r1.f2.we <= 1;
    @cb;
    cb.hwif_in.r1.f1.next <= 0;
    cb.hwif_in.r1.f2.next <= 0;
    cb.hwif_in.r1.f1.we <= 0;
    cb.hwif_in.r1.f2.we <= 0;
    cpuif.assert_read('h0, 12);
    assert(cb.hwif_out.r1.f1.value == 12);
    assert(cb.hwif_out.r1.f2.value == 0);


    // r2 - sw=rw; hw=r; // Storage element
    cpuif.assert_read('h1, 20 + (1 << 7));
    assert(cb.hwif_out.r2.f1.value == 20);
    assert(cb.hwif_out.r2.f2.value == 1);

    cpuif.write('h1, 21);
    cpuif.assert_read('h1, 21);
    assert(cb.hwif_out.r2.f1.value == 21);
    assert(cb.hwif_out.r2.f2.value == 0);


    // r3 - sw=rw; hw=w; wel; // Storage element
    cpuif.assert_read('h2, 30);

    cpuif.write('h2, 31 + (1 << 7));
    cpuif.assert_read('h2, 31 + (1 << 7));

    cb.hwif_in.r3.f1.next <= 29;
    cb.hwif_in.r3.f2.next <= 0;
    cpuif.assert_read('h2, 31 + (1 << 7));
    cb.hwif_in.r3.f1.next <= 32;
    cb.hwif_in.r3.f2.next <= 0;
    cb.hwif_in.r3.f1.wel <= 0;
    cb.hwif_in.r3.f2.wel <= 0;
    @cb;
    cb.hwif_in.r3.f1.next <= 0;
    cb.hwif_in.r3.f2.next <= 0;
    cb.hwif_in.r3.f1.wel <= 1;
    cb.hwif_in.r3.f2.wel <= 1;
    cpuif.assert_read('h2, 32);


    // r4 - sw=rw; hw=na; // Storage element
    cpuif.assert_read('h3, 40 + (1 << 7));
    cpuif.write('h3, 41);
    cpuif.assert_read('h3, 41);


    // r5 - sw=r; hw=rw; we; // Storage element
    cpuif.assert_read('h4, 50);
    assert(cb.hwif_out.r5.f1.value == 50);

    cpuif.write('h4, 51 + (1 << 7));
    cpuif.assert_read('h4, 50);
    assert(cb.hwif_out.r5.f1.value == 50);
    assert(cb.hwif_out.r5.f2.value == 0);

    cb.hwif_in.r5.f1.next <= 9;
    cb.hwif_in.r5.f2.next <= 1;
    cpuif.assert_read('h4, 50);
    assert(cb.hwif_out.r5.f1.value == 50);
    assert(cb.hwif_out.r5.f2.value == 0);
    cb.hwif_in.r5.f1.next <= 52;
    cb.hwif_in.r5.f2.next <= 1;
    cb.hwif_in.r5.f1.we <= 1;
    cb.hwif_in.r5.f2.we <= 1;
    @cb;
    cb.hwif_in.r5.f1.next <= 0;
    cb.hwif_in.r5.f2.next <= 0;
    cb.hwif_in.r5.f1.we <= 0;
    cb.hwif_in.r5.f2.we <= 0;
    cpuif.assert_read('h4, 52 + (1 << 7));
    assert(cb.hwif_out.r5.f1.value == 52);
    assert(cb.hwif_out.r5.f2.value == 1);


    // r6 - sw=r; hw=r; // Wire/Bus - constant value
    cpuif.assert_read('h5, 60 + (1 << 7));
    assert(cb.hwif_out.r6.f1.value == 60);
    assert(cb.hwif_out.r6.f2.value == 1);
    cpuif.write('h5, 61);
    cpuif.assert_read('h5, 60 + (1 << 7));
    assert(cb.hwif_out.r6.f1.value == 60);
    assert(cb.hwif_out.r6.f2.value == 1);


    // r7 - sw=r; hw=w; // Wire/Bus - hardware assigns value
    cpuif.assert_read('h6, 0);
    cb.hwif_in.r7.f1.next <= 70;
    cb.hwif_in.r7.f2.next <= 1;
    cpuif.assert_read('h6, 70 + (1 << 7));
    cpuif.write('h6, 71);
    cpuif.assert_read('h6, 70 + (1 << 7));


    // r8 - sw=r; hw=na; // Wire/Bus - constant value
    cpuif.assert_read('h7, 80);
    cpuif.write('h7, 81 + (1 << 7));
    cpuif.assert_read('h7, 80);


    // r9 - sw=w; hw=rw; we; // Storage element
    cpuif.assert_read('h8, 0);
    assert(cb.hwif_out.r9.f1.value == 90);
    assert(cb.hwif_out.r9.f2.value == 1);

    cpuif.write('h8, 91);
    cpuif.assert_read('h8, 0);
    assert(cb.hwif_out.r9.f1.value == 91);
    assert(cb.hwif_out.r9.f2.value == 0);

    cb.hwif_in.r9.f1.next <= 89;
    cb.hwif_in.r9.f2.next <= 1;
    cpuif.assert_read('h8, 0);
    assert(cb.hwif_out.r9.f1.value == 91);
    assert(cb.hwif_out.r9.f2.value == 0);
    cb.hwif_in.r9.f1.next <= 92;
    cb.hwif_in.r9.f2.next <= 1;
    cb.hwif_in.r9.f1.we <= 1;
    cb.hwif_in.r9.f2.we <= 1;
    @cb;
    cb.hwif_in.r9.f1.next <= 0;
    cb.hwif_in.r9.f2.next <= 0;
    cb.hwif_in.r9.f1.we <= 0;
    cb.hwif_in.r9.f2.we <= 0;
    cpuif.assert_read('h8, 0);
    assert(cb.hwif_out.r9.f1.value == 92);
    assert(cb.hwif_out.r9.f2.value == 1);


    // r10 - sw=w; hw=r; // Storage element
    cpuif.assert_read('h9, 0);
    assert(cb.hwif_out.r10.f1.value == 100);
    assert(cb.hwif_out.r10.f2.value == 0);

    cpuif.write('h9, 101 + (1 << 7));
    cpuif.assert_read('h9, 0);
    assert(cb.hwif_out.r10.f1.value == 101);
    assert(cb.hwif_out.r10.f2.value == 1);

{% endblock %}
