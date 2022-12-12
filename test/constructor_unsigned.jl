@testset "construct BitVector from Unsigned" begin
    # truncation
    for u in (0x12, 0x1234, 0x12345678, 0x123456789abcdef, 0x0f1e2d3c4b5a69780123456789abcdef)
        sz = 8sizeof(u)
        for n = 0:sz
            m = sz - n
            @test BitVector(u, n) == BitVector(u << m >> m, n)
        end
    end
    # (bit)reverse
    for u in (0x12, 0x1234, 0x12345678, 0x123456789abcdef, 0x0f1e2d3c4b5a69780123456789abcdef)
        for T in (UInt8, UInt16, UInt32, UInt64)
            t = u % T
            b = BitVector(t)
            rb = reverse(b)
            @test rb.chunks[1] == bitreverse(t)
        end
    end
    b = BitVector(UInt128(0xf5))
    rb = reverse(b)
    @test rb.chunks[1] == 0x0000000000000000
    @test rb.chunks[2] == bitreverse(UInt128(0xf5)) >> 64 % UInt64

    # there and back again
    is = [1,5,32]
    @test bitonehot(is) == BitVector(0x80000011)
    is = [1,4,6,8]
    @test bitonehot(is) == BitVector(0xa9)

    # rotation -- somewhat excessive since circshift is already the same as bitrotate.
    # (it's correct by construction, but a desirable property)
    for u in (0x12, 0x1234, 0x12345678, 0x123456789abcdef, 0x0f1e2d3c4b5a69780123456789abcdef)
        b = BitVector(u)
        sz = 8sizeof(u)
        for n = -sz:sz
            @test circshift(b, n) == BitVector(bitrotate(u, n))
        end
    end

    # other properties
    for u in (0xf5, 0xf0, 0x0f, 0x10, 0x01, 0x12, 0x1234, 0x12345678, 0x123456789abcdef, 0x0f1e2d3c4b5a69780123456789abcdef)
        B = BitVector(u)
        @test sum(B) == count_ones(u)
        @test findfirst(B) == trailing_zeros(u) + 1
        @test findlast(B) == 8sizeof(u) - leading_zeros(u)
    end
end
