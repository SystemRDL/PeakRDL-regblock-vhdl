from typing import TYPE_CHECKING

from systemrdl.node import FieldNode, RegNode

from ..struct_generator import RDLFlatStructGenerator
from ..identifier_filter import kw_filter as kwf

if TYPE_CHECKING:
    from . import WriteBuffering
    from systemrdl.node import Node

class WBufStorageStructGenerator(RDLFlatStructGenerator):
    def __init__(self, wbuf: 'WriteBuffering') -> None:
        super().__init__()
        self.wbuf = wbuf

    def get_typdef_name(self, node:'Node', suffix: str = "") -> str:
        base = node.get_rel_path(
            self.wbuf.top_node.parent,
            hier_separator=".",
            array_suffix="",
            empty_array_suffix=""
        )
        return kwf(f'{base}{suffix}_wbuf_storage_t')

    def enter_Field(self, node: FieldNode) -> None:
        # suppress parent class's field behavior
        pass

    def enter_Reg(self, node: RegNode) -> None:
        super().enter_Reg(node)

        if not node.get_property('buffer_writes'):
            return

        regwidth = node.get_property('regwidth')
        self.add_member("data", regwidth)
        self.add_member("biten", regwidth)
        self.add_member("pending")

        trigger = node.get_property('wbuffer_trigger')
        if isinstance(trigger, RegNode) and trigger == node:
            self.add_member("trigger_q")
