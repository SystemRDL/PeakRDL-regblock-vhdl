import re
from typing import Match, Union, Optional, overload

from systemrdl.rdltypes.references import PropertyReference
from systemrdl.node import Node, AddrmapNode, FieldNode

from .identifier_filter import kw_filter as kwf
from .vhdl_int import VhdlInt


def get_indexed_path(top_node: Node, target_node: Node) -> str:
    """
    TODO: Add words about indexing and why i'm doing this. Copy from logbook
    """
    path = target_node.get_rel_path(top_node, empty_array_suffix="(!)")

    # replace unknown indexes with incrementing iterators i0, i1, ...
    class ReplaceUnknown:
        def __init__(self) -> None:
            self.i = 0
        def __call__(self, match: Match) -> str:
            s = f'i{self.i}'
            self.i += 1
            return s
    path = re.sub(r'!', ReplaceUnknown(), path)
    # change multidimensonal indices from (x)(y)(z) to (x, y, z)
    path = re.sub(r'\)\(', ', ', path)

    # Sanitize any VHDL keywords
    def kw_filter_repl(m: Match) -> str:
        return kwf(m.group(0))
    path = re.sub(r'\w+', kw_filter_repl, path)

    return path

def clog2(n: int) -> int:
    return (n-1).bit_length()

def is_pow2(x: int) -> bool:
    return (x > 0) and ((x & (x - 1)) == 0)

def roundup_pow2(x: int) -> int:
    return 1<<(x-1).bit_length()

def ref_is_internal(top_node: AddrmapNode, ref: Union[Node, PropertyReference]) -> bool:
    """
    Determine whether the reference is internal to the top node.

    For the sake of this exporter, root signals are treated as internal.
    """
    current_node: Optional[Node]
    if isinstance(ref, Node):
        current_node = ref
    elif isinstance(ref, PropertyReference):
        current_node = ref.node
    else:
        raise RuntimeError

    while current_node is not None:
        if current_node == top_node:
            # reached top node without finding any external components
            # is internal!
            return True

        if current_node.external:
            # not internal!
            return False

        current_node = current_node.parent

    # A root signal was referenced, which dodged the top addrmap
    # This is considered internal for this exporter
    return True


def do_slice(value: Union[VhdlInt, str], high: int, low: int, reduce: bool=True) -> Union[VhdlInt, str]:
    if isinstance(value, str):
        # If string, assume this is an identifier. Append bit-slice
        if high == low and reduce:
            return f"{value}({low})"
        else:
            return f"{value}({high} downto {low})"
    else:
        # it is a VhdlInt literal. Slice it down
        mask = (1 << (high + 1)) - 1
        v = (value.value & mask) >> low

        if value.width is not None:
            w = high - low + 1
        else:
            w = None

        return VhdlInt(v, w, value.kind, value.allow_std_logic)

def do_bitswap(value: Union[VhdlInt, str]) -> Union[VhdlInt, str]:
    if isinstance(value, str):
        # If string, assume this is an identifier. Wrap in a function
        return f"bitswap({value})"
    else:
        # it is a VhdlInt literal. bitswap it
        assert value.width is not None # width must be known!
        v = value.value
        vswap = 0
        for _ in range(value.width):
            vswap = (vswap << 1) + (v & 1)
            v >>= 1
        return VhdlInt(vswap, value.width, value.kind, value.allow_std_logic)

class ArrayWidth(int):
    """Integer subtype representing an array width (positive integer).
    Ensures the value is an int >= 1.

    Used to represent the width of an array (std_logic_vector) so that
    a non-array (std_logic) is not inferred.
    """
    def __new__(cls, value: int) -> "ArrayWidth":
        if not isinstance(value, int):
            raise TypeError(f"ArrayWidth must be an int, got {type(value).__name__}")
        if value < 1:
            raise ValueError(f"ArrayWidth must be >= 1, got {value}")
        return int.__new__(cls, value)

    def __repr__(self) -> str:
        return f"ArrayWidth({int(self)})"

@overload
def get_vhdl_type(width: FieldNode) -> str: ...

@overload
def get_vhdl_type(width: int, fracwidth: Optional[int], is_signed: Optional[bool]) -> str: ...

def get_vhdl_type(
        width: Union[FieldNode, int],
        fracwidth: Optional[int]=None,
        is_signed: Optional[bool]=None,
) -> str:
    if isinstance(width, FieldNode):
        obj = width
        width = obj.width
        is_signed = obj.get_property("is_signed")
        fracwidth = obj.get_property("fracwidth")

    if fracwidth is not None:
        if is_signed:
            return "sfixed"
        else:
            return "ufixed"
    elif is_signed is not None:
        if is_signed:
            return "signed"
        else:
            return "unsigned"
    else:
        if width == 1 and not isinstance(width, ArrayWidth):
            return "std_logic"
        else:
            return "std_logic_vector"

def get_vhdl_type_slice_bounds(width: int, fracwidth: Optional[int], is_signed: Optional[bool]) -> str:
    vhdl_type = get_vhdl_type(width, fracwidth, is_signed)
    if vhdl_type == "std_logic":
        return ""

    lsb = 0 if fracwidth is None else -fracwidth
    return f"({width + lsb - 1} downto {lsb})"
