using BitVectorExtensions
using Test
using BitVectorExtensions: bitonehot
using Random

@testset "BitVectorExtensions.jl" begin
    include("constructor_unsigned.jl")
    include("shifts.jl")
end
