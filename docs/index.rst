Introduction
============

PeakRDL-regblock-vhdl is a free and open-source control & status register (CSR) compiler.
This code generator translates your SystemRDL register description into
a synthesizable VHDL RTL module that can be easily instantiated into
your hardware design.

* Generates fully synthesizable VHDL RTL (IEEE 1076-2008)
* Options for many popular CPU interface protocols (AMBA APB, AXI4-Lite, and more)
* Configurable pipelining options for designs with fast clock rates.
* Broad support for SystemRDL 2.0 features


Quick Start
-----------
The easiest way to use PeakRDL-regblock-vhdl is via the  `PeakRDL command line tool <https://peakrdl.readthedocs.io/>`_:

.. code-block:: bash

    # Install PeakRDL-regblock-vhdl along with the command-line tool
    python3 -m pip install peakrdl-regblock-vhdl[cli]

    # Export!
    peakrdl regblock atxmega_spi.rdl -o regblock/ --cpuif axi4-lite


Links
-----

- `Source repository <https://github.com/SystemRDL/PeakRDL-regblock>`_
- `Release Notes <https://github.com/SystemRDL/PeakRDL-regblock/releases>`_
- `Issue tracker <https://github.com/SystemRDL/PeakRDL-regblock/issues>`_
- `PyPi <https://pypi.org/project/peakrdl-regblock>`_
- `SystemRDL Specification <http://accellera.org/downloads/standards/systemrdl>`_


.. toctree::
    :hidden:

    self
    architecture
    hwif
    configuring
    limitations
    faq
    licensing
    api

.. toctree::
    :hidden:
    :caption: CPU Interfaces

    cpuif/introduction
    cpuif/apb
    cpuif/axi4lite
    cpuif/avalon
    cpuif/passthrough
    cpuif/internal_protocol
    cpuif/customizing

.. toctree::
    :hidden:
    :caption: SystemRDL Properties

    props/field
    props/reg
    props/addrmap
    props/signal
    props/rhs_props

.. toctree::
    :hidden:
    :caption: Other SystemRDL Features

    rdl_features/external

.. toctree::
    :hidden:
    :caption: Extended Properties

    udps/intro
    udps/read_buffering
    udps/write_buffering
    udps/extended_swacc
