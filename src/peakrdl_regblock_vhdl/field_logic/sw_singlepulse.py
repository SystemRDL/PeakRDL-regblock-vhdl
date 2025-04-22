from typing import TYPE_CHECKING, List

from .bases import NextStateUnconditional
from ..vhdl_int import VhdlInt

if TYPE_CHECKING:
    from systemrdl.node import FieldNode

class Singlepulse(NextStateUnconditional):
    comment = "singlepulse clears back to 0"
    unconditional_explanation = "The 'singlepulse' property unconditionally clears a field when not written"

    def is_match(self, field: 'FieldNode') -> bool:
        return field.get_property('singlepulse')

    def get_assignments(self, field: 'FieldNode') -> List[str]:
        zero = VhdlInt.zeros(field.width)
        return [
            f"next_c := {zero};",
            "load_next_c := '1';",
        ]
