function bitonehot(I::Vector{Int}, n::Int)
    b = falses(n)
    for i ∈ I
        b[i] = true
    end
    b
end
bitonehot(I::Vector{Int}) = bitonehot(I, maximum(I))

function sum_to_int(b::BitVector)
    s = 0
    for i ∈ eachindex(b)
        s += b[i] * 2^(i - 1)
    end
    s
end
