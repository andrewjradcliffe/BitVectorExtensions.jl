## Constructors from Unsigned ##
@noinline throw_invalid_nbits(n::Integer) = throw(ArgumentError("length must be ≤ 128, got $n"))

"""
    BitVector(x::Unsigned, n::Integer)

Construct a `BitVector` of length 0 ≤ `n` ≤ 128 from an unsigned integer.
If `n < 8sizeof(x)`, only the first `n` bits, numbering from the right, will be
preserved; this is equivalent to `m = 8sizeof(x) - n; BitVector(x << m >> m, n)`.
If `n > 8sizeof(x)`, the leading bit positions (reading left to right) are
zero-filled analogously to unsigned integer literals.

# Examples
```jldoctest
julia> B = BitVector(0b101, 4)
4-element BitVector:
 1
 0
 1
 0

julia> B == BitVector((true, false, true, false))
true

julia> B == BitVector(0xf5, 4)
true

julia> BitVector(0xff, 0)
0-element BitVector

julia> m = 8sizeof(0xf5) - 3
5

julia> BitVector(0xf5 << m >> m, 3) == BitVector(0xf5, 3)
true

julia> BitVector(0b110, 8sizeof(0b110) - leading_zeros(0b110))
3-element BitVector:
 0
 1
 1
```
"""
function BitVector(x::Unsigned, n::Integer)
    n ≤ 128 || throw_invalid_nbits(n)
    B = BitVector(undef, n)
    Bc = B.chunks
    n != 0 && (Bc[1] = _msk64 >> (64 - n) & x)
    n > 64 && (Bc[2] = ~_msk64)
    return B
end

"""
    BitVector(x::Unsigned)

Construct a `BitVector` of length `8sizeof(x)` from an unsigned integer following
the [LSB 0 bit numbering scheme](https://en.wikipedia.org/wiki/Bit_numbering)
(except 1-indexed). Leading bit positions are zero-filled analogously to unsigned
integer literals.

# Examples
```jldoctest
julia> BitVector(0b10010100)
8-element BitVector:
 0
 0
 1
 0
 1
 0
 0
 1

julia> BitVector(0b10100)
8-element BitVector:
 0
 0
 1
 0
 1
 0
 0
 0

julia> BitVector(0xff) == trues(8)
true
```
"""
BitVector(x::Unsigned) = BitVector(x, 8 * sizeof(x))

function BitVector(x::UInt128)
    B = BitVector(undef, 128)
    Bc = B.chunks
    Bc[1] = x % UInt64
    Bc[2] = x >> 64 % UInt64
    return B
end

function BitVector(x::UInt128, n::Integer)
    n ≤ 128 || throw_invalid_nbits(n)
    B = BitVector(undef, n)
    if n != 0
        Bc = B.chunks
        y = _msk128 >> (128 - n) & x
        Bc[1] = y % UInt64
        n > 64 && (Bc[2] = y >> 64 % UInt64)
    end
    return B
end
