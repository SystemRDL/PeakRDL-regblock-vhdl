[![Documentation Status](https://readthedocs.org/projects/peakrdl-regblock/badge/?version=latest)](http://peakrdl-regblock.readthedocs.io)
[![build](https://github.com/SystemRDL/PeakRDL-regblock-vhdl/workflows/build/badge.svg)](https://github.com/SystemRDL/PeakRDL-regblock-vhdl/actions?query=workflow%3Abuild+branch%3Amain)
[![Coverage Status](https://coveralls.io/repos/github/SystemRDL/PeakRDL-regblock-vhdl/badge.svg?branch=main)](https://coveralls.io/github/SystemRDL/PeakRDL-regblock-vhdl?branch=main)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/peakrdl-regblock-vhdl.svg)](https://pypi.org/project/peakrdl-regblock-vhdl)

# PeakRDL-regblock-vhdl
Compile SystemRDL into a VHDL control/status register (CSR) block. This is a VHDL port of the [SystemVerliog PeakRDL-regblock exporter](https://github.com/SystemRDL/PeakRDL-regblock).

For the command line tool, see the [PeakRDL project](https://peakrdl.readthedocs.io).

## Documentation
See the [PeakRDL-regblock Documentation](http://peakrdl-regblock.readthedocs.io) for more details

## Relationship with PeakRDL-regblock
This is a direct port of the SystemVerilog regblock generator PeakRDL-regblock. Updates from the upstream regblock implementation are converted to VHDL and merged into this repository.

If you encounter an issue,
1. Check if it is already reported in the upstream repository's [issue tracker](https://github.com/SystemRDL/PeakRDL-regblock/issues).
2. Report it in the upstream repository (unless you are sure it's unique to the VHDL port).
3. The upstream fix will be merged into this VHDL port.
