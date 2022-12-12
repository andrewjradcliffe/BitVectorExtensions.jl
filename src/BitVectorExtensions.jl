module BitVectorExtensions

export rshift, rshift!, lshift, lshift!

import Base: BitVector, copy_chunks!, get_chunks_id, _msk64, glue_src_bitchunks, _div64, _mod64, copy_chunks_rtol!

const _msk128 = ~UInt128(0)

include("constructor_unsigned.jl")
include("shifts.jl")
include("utils.jl")

end
