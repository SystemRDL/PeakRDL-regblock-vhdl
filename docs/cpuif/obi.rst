Open Bus Interface (OBI)
========================

Implements the register block using an `OBI <https://github.com/openhwgroup/obi>`_
CPU interface.

The OBI interface comes in two i/o port flavors:

VHDL Record Interface
    * Command line: ``--cpuif obi``
    * Interface Definition: :download:`obi_intf_pkg.vhd <../../hdl-src/obi_intf_pkg.vhd>`
    * Class: :class:`peakrdl_regblock_vhdl.cpuif.obi.OBI_Cpuif`

Flattened inputs/outputs
    Flattens the interface into discrete input and output ports.

    * Command line: ``--cpuif obi-flat``
    * Class: :class:`peakrdl_regblock_vhdl.cpuif.obi.OBI_Cpuif_flattened`
