# Necessary for avoiding a copy on rshift! when dest===src
# -- several of the bitshifts involving ld0 can probably be eliminated.
function copy_chunks_rshift!(dest::Vector{UInt64}, pos_d::Int, src::Vector{UInt64}, pos_s::Int, numbits::Int)
    numbits == 0 && return
    if dest === src && pos_d > pos_s
        return copy_chunks_rtol!(dest, pos_d, pos_s, numbits)
    end

    kd0, ld0 = get_chunks_id(pos_d)
    kd1, ld1 = get_chunks_id(pos_d + numbits - 1)
    ks0, ls0 = get_chunks_id(pos_s)
    ks1, ls1 = get_chunks_id(pos_s + numbits - 1)

    delta_kd = kd1 - kd0
    delta_ks = ks1 - ks0

    u = _msk64
    if delta_kd == 0
        msk_d0 = ~(u << ld0) | (u << (ld1+1))
    else
        msk_d0 = ~(u << ld0)
        msk_d1 = (u << (ld1+1))
    end
    if delta_ks == 0
        msk_s0 = (u << ls0) & ~(u << (ls1+1))
    else
        msk_s0 = (u << ls0)
    end

    chunk_s0 = glue_src_bitchunks(src, ks0, ks1, msk_s0, ls0)

    dest[kd0] = ((chunk_s0 << ld0) & ~msk_d0)

    if delta_kd == 0
        for i = kd0+1:length(dest)
            dest[i] = ~_msk64
        end
        return
    end

    for i = 1 : kd1 - kd0 - 1
        chunk_s1 = glue_src_bitchunks(src, ks0 + i, ks1, msk_s0, ls0)

        chunk_s = (chunk_s0 >>> (64 - ld0)) | (chunk_s1 << ld0)

        dest[kd0 + i] = chunk_s

        chunk_s0 = chunk_s1
    end

    if ks1 >= ks0 + delta_kd
        chunk_s1 = glue_src_bitchunks(src, ks0 + delta_kd, ks1, msk_s0, ls0)
    else
        chunk_s1 = UInt64(0)
    end

    chunk_s = (chunk_s0 >>> (64 - ld0)) | (chunk_s1 << ld0)

    dest[kd1] = (chunk_s & ~msk_d1)

    for i = kd1+1:length(dest)
        dest[i] = ~_msk64
    end

    return
end

@inline function _msk_rtol!(dest::Vector{UInt64}, i::Int)
    kd1, ld1 = get_chunks_id(i)
    dest[kd1] &= (_msk64 << (ld1+1))
    for k = kd1-1:-1:1
        dest[k] = ~_msk64
    end
    return
end

function rshift!(dest::BitVector, src::BitVector, i::Int)
    length(dest) == length(src) || throw(ArgumentError("destination and source should be of same size"))
    n = length(dest)
    abs(i) < n || return fill!(dest, false)
    i == 0 && return (src === dest ? src : copyto!(dest, src))
    if i > 0 # right
        copy_chunks_rshift!(dest.chunks, 1, src.chunks, i+1, n-i)
    else # left
        i = -i
        copy_chunks_rshift!(dest.chunks, i+1, src.chunks, 1, n-i)
        _msk_rtol!(dest.chunks, i)
    end
    return dest
end

"""
    rshift!(dest::BitVector, src::BitVector, i::Integer)

Shift the elements of `src` right by `n` bit positions, filling with `false` values,
storing the result in `dest`. If `n < 0`, elements are shifted to the left.

See also: [`rshift`](@ref), [`lshift!`](@ref)

# Examples
```jldoctest
julia> B = BitVector((false, false, false));

julia> rshift!(B, BitVector((true, true, true,)), 2)
3-element BitVector:
 1
 0
 0

julia> rshift!(B, BitVector((true, true, true,)), -2)
3-element BitVector:
 0
 0
 1
```
"""
rshift!(dest::BitVector, src::BitVector, i::Integer) = rshift!(dest, src, Int(i))

"""
    rshift!(B::BitVector, i::Integer)

Shift the elements of `B` right by `n` bit positions, filling with `false` values.
If `n < 0`, elements are shifted to the left.

# Examples
```jldoctest
julia> B = BitVector((true, true, true));

julia> rshift!(B, 2)
3-element BitVector:
 1
 0
 0

julia> rshift!(B, 1)
3-element BitVector:
 0
 0
 0
```
"""
rshift!(B::BitVector, i::Integer) = rshift!(B, B, i)

# Same as (<<)(B::BitVector, i::UInt)
"""
    rshift(B::BitVector, n::Integer)

Return `B` with the elements shifted right by `n` bit positions, filling with
`false` values. If `n < 0`, elements are shifted to the left.

See also: [`rshift!`](@ref), [`lshift`](@ref)

# Examples
```jldoctest
julia> B = BitVector([true, false, true, false, false])
5-element BitVector:
 1
 0
 1
 0
 0
julia> rshift(B, 1) == B << 1    # Notice opposite behavior
true

julia> rshift(B, 2)
5-element BitVector:
 1
 0
 0
 0
 0
```
"""
rshift(B::BitVector, i::Integer) = rshift!(similar(B), B, i)


"""
    lshift!(dest::BitVector, src::BitVector, i::Integer)

Shift the elements of `src` left by `n` bit positions, filling with `false` values,
storing the result in `dest`. If `n < 0`, elements are shifted to the right.

See also: [`lshift`](@ref), [`rshift!`](@ref)

# Examples
```jldoctest
julia> B = BitVector((false, false, false));

julia> lshift!(B, BitVector((true, true, true,)), 2)
3-element BitVector:
 0
 0
 1

julia> lshift!(B, BitVector((true, true, true,)), -2)
3-element BitVector:
 1
 0
 0
```
"""
lshift!(dest::BitVector, src::BitVector, i::Integer) = rshift!(dest, src, -i)
lshift!(dest::BitVector, src::BitVector, i::Unsigned) = rshift!(dest, src, -Int(i))

"""
    lshift!(B::BitVector, i::Integer)

Shift the elements of `B` left by `n` bit positions, filling with `false` values.
If `n < 0`, elements are shifted to the right.

# Examples
```jldoctest
julia> B = BitVector((true, true, true));

julia> lshift!(B, 2)
3-element BitVector:
 0
 0
 1

julia> lshift!(B, 1)
3-element BitVector:
 0
 0
 0
"""
lshift!(B::BitVector, i::Integer) = lshift!(B, B, i)

# Same as (>>>)(B::BitVector, i::UInt)
"""
    lshift(B::BitVector, n::Integer)

Return `B` with the elements shifted left by `n` bit positions, filling with
`false` values. If `n < 0`, elements are shifted to the right.

See also: [`rshift`](@ref)

# Examples
```jldoctest
julia> B = BitVector([true, false, true, false, false])
5-element BitVector:
 1
 0
 1
 0
 0
julia> lshift(B, 1) == B >> 1    # Notice opposite behavior
true

julia> lshift(B, 2)
5-element BitVector:
 0
 0
 1
 0
 1
```
"""
lshift(B::BitVector, i::Integer) = lshift!(similar(B), B, i)
