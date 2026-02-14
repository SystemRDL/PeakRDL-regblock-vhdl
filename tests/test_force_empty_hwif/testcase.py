import os

from ..lib.base_testcase import BaseTestCase


class _BaseForceHwifCase(BaseTestCase):
    def _read_generated(self):
        run_dir = self.get_run_dir()
        with open(os.path.join(run_dir, "vhdl_regblock_pkg.vhd"), encoding="utf-8") as f:
            pkg = f.read()
        with open(os.path.join(run_dir, "vhdl_regblock.vhd"), encoding="utf-8") as f:
            mod = f.read()
        return pkg, mod


class TestNoForce(_BaseForceHwifCase):
    def test_no_hwif_ports(self):
        pkg, mod = self._read_generated()

        assert "type regblock_in_t is record" not in pkg
        assert "type regblock_out_t is record" not in pkg
        assert "\\0_dummy_entry\\" not in pkg

        assert "hwif_in : in regblock_in_t" not in mod
        assert "hwif_out : out regblock_out_t" not in mod
        assert "hwif_out.\\0_dummy_entry\\ <= '0';" not in mod


class TestForceInOnly(_BaseForceHwifCase):
    force_hwif_in = True

    def test_force_hwif_in(self):
        pkg, mod = self._read_generated()

        assert "type regblock_in_t is record" in pkg
        assert "\\0_dummy_entry\\ : std_logic;" in pkg
        assert "type regblock_out_t is record" not in pkg

        assert "hwif_in : in regblock_in_t := (\\0_dummy_entry\\ => '0')" in mod
        assert "hwif_out : out regblock_out_t" not in mod
        assert "hwif_out.\\0_dummy_entry\\ <= '0';" not in mod


class TestForceOutOnly(_BaseForceHwifCase):
    force_hwif_out = True

    def test_force_hwif_out(self):
        pkg, mod = self._read_generated()

        assert "type regblock_out_t is record" in pkg
        assert "\\0_dummy_entry\\ : std_logic;" in pkg
        assert "type regblock_in_t is record" not in pkg

        assert "hwif_out : out regblock_out_t" in mod
        assert "hwif_in : in regblock_in_t" not in mod
        assert "hwif_out.\\0_dummy_entry\\ <= '0';" in mod


class TestForceBoth(_BaseForceHwifCase):
    force_hwif_in = True
    force_hwif_out = True

    def test_force_both(self):
        pkg, mod = self._read_generated()

        assert "type regblock_in_t is record" in pkg
        assert "type regblock_out_t is record" in pkg
        assert pkg.count("\\0_dummy_entry\\ : std_logic;") == 2

        assert "hwif_in : in regblock_in_t := (\\0_dummy_entry\\ => '0')" in mod
        assert "hwif_out : out regblock_out_t" in mod
        assert "hwif_out.\\0_dummy_entry\\ <= '0';" in mod
