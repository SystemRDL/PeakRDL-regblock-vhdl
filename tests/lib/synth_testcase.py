from typing import List
import os

import pytest

from .base_testcase import BaseTestCase
from .synthesizers import get_synthesizer_cls

class SynthTestCase(BaseTestCase):

    def _get_synth_files(self) -> List[str]:
        files = []
        files.extend(file for file in self.cpuif.get_synth_files() if file.endswith(".vhd"))
        files.append("vhdl_regblock_pkg.vhd")
        files.append("vhdl_regblock.vhd")
        files.append("../../../../hdl-src/reg_utils.vhd")

        return files

    def setUp(self) -> None:
        name = self.request.config.getoption("--synth-tool")
        synth_cls = get_synthesizer_cls(name)
        if synth_cls is None:
            pytest.skip()
        super().setUp()

    def run_synth(self) -> None:
        name = self.request.config.getoption("--synth-tool")
        synth_cls = get_synthesizer_cls(name)
        synth = synth_cls(self)

        # cd into the build directory
        cwd = os.getcwd()
        os.chdir(self.get_run_dir())

        try:
            synth.run()
        finally:
            # cd back
            os.chdir(cwd)
