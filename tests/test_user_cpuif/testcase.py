import os

from peakrdl_regblock.cpuif.apb3 import APB3_Cpuif as SvAPB3_Cpuif
from peakrdl_regblock_vhdl.cpuif.apb3 import APB3_Cpuif as VhdlAPB3_Cpuif
from ..lib.cpuifs.apb3 import APB3
from ..lib.base_testcase import BaseTestCase


#-------------------------------------------------------------------------------

class SvClassOverride_Cpuif(SvAPB3_Cpuif):
    @property
    def port_declaration(self) -> str:
        return "user_apb3_intf.slave s_apb"


class VhdlClassOverride_Cpuif(VhdlAPB3_Cpuif):
    @property
    def port_declaration(self) -> str:
        return super().port_declaration.replace(" apb3_slave_", " user_apb3_slave_")


class ClassOverride_cpuiftestmode(APB3):
    sv_cpuif_cls = SvClassOverride_Cpuif
    vhdl_cpuif_cls = VhdlClassOverride_Cpuif


class Test_class_override(BaseTestCase):
    cpuif = ClassOverride_cpuiftestmode()

    def test_override_success(self):
        output_file = os.path.join(self.get_run_dir(), "regblock.sv")
        with open(output_file, "r") as f:
            self.assertIn(
                "user_apb3_intf.slave s_apb",
                f.read()
            )

#-------------------------------------------------------------------------------

class SvTemplateOverride_Cpuif(SvAPB3_Cpuif):
    # contains the text "USER TEMPLATE OVERRIDE"
    template_path = "user_apb3_tmpl.sv"


class VhdlTemplateOverride_Cpuif(VhdlAPB3_Cpuif):
    # contains the text "USER TEMPLATE OVERRIDE"
    template_path = "user_apb3_tmpl.sv"


class TemplateOverride_cpuiftestmode(APB3):
    sv_cpuif_cls = SvTemplateOverride_Cpuif
    vhdl_cpuif_cls = VhdlTemplateOverride_Cpuif


class Test_template_override(BaseTestCase):
    cpuif = TemplateOverride_cpuiftestmode()

    def test_override_success(self):
        for regblock in ("regblock.sv", "vhdl_regblock.vhd"):
            output_file = os.path.join(self.get_run_dir(), regblock)
            with open(output_file, "r") as f:
                self.assertIn(
                    "USER TEMPLATE OVERRIDE",
                    f.read()
                )
