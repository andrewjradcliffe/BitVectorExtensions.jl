@testset "BitVector l/r-shift[!] tests" begin
    b = BitVector(0x123456789abcdef)
    for i = -65:65
        r = rshift(b, i)
        @test r.chunks[1] == 0x123456789abcdef >> i
        l = lshift(b, i)
        @test l.chunks[1] == 0x123456789abcdef << i
        # test vs. extant behavior of shift operators
        @test r == b << i
        @test l == b >> i
    end
    b = BitVector(0x0f1e2d3c4b5a69780123456789abcdef)
    for i = -129:129
        r = rshift(b, i)
        @test r.chunks[1] == 0x0f1e2d3c4b5a69780123456789abcdef >> i % UInt64
        @test r.chunks[2] == 0x0f1e2d3c4b5a69780123456789abcdef >> i >> 64 % UInt64
        l = lshift(b, i)
        @test l.chunks[1] == 0x0f1e2d3c4b5a69780123456789abcdef << i % UInt64
        @test l.chunks[2] == 0x0f1e2d3c4b5a69780123456789abcdef << i >> 64 % UInt64
        # test vs. extant behavior of shift operators
        @test r == b << i
        @test l == b >> i
    end
    # With truncation
    @test rshift(BitVector(0x123456789abcdef, 20), 10) == BitVector(0xbcdef >> 10, 20)
    @test lshift(BitVector(0x123456789abcdef, 20), 10) == BitVector(0xbcdef << 10, 20)
    # Mutation: into self and into another dest
    b = BitVector(0xffffffffffffffff)
    @test_throws ArgumentError rshift!(b, falses(3), 2)
    @test_throws ArgumentError lshift!(b, falses(3), 2)
    for n in (64, 65, 79, 127, 128, 129, 158, 191, 192, 193, 1023, 1024, 1025)
        b = trues(n)
        t = trues(n)
        c = similar(b)
        # push bits off one by one
        for i = n-1:-1:0
            rshift!(b, 1)
            rshift!(c, t, n-i)
            @test sum(b) == i == sum(c)
        end
        # place bit at right-most, then walk it to left-most, then back again
        b .= false
        b[1] = true
        for r = (2:1:n, -(n-1):1:-1)
            for i = r
                rshift!(b, signbit(i) ? 1 : -1)
                @test b[abs(i)]
            end
        end
        rshift!(b, t, 0)
        @test all(b)
        @test b.chunks !== t.chunks
        for i in (1, 2, 3, 4, 5, 17, 24, 37, 63, 64)
            rshift!(b, t, 0)
            rshift!(b, i)
            rshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
        end
        for i = n-2:n
            rshift!(b, t, 0)
            rshift!(b, i)
            rshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
        end
        for i = 64:64:n-1
            rshift!(b, t, 0)
            rshift!(b, i)
            rshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
            rshift!(b, t, 0)
            rshift!(b, i - 1)
            rshift!(c, t, i - 1)
            @test sum(b) == n - (i - 1) == sum(c)
            rshift!(b, t, 0)
            rshift!(b, i + 1)
            rshift!(c, t, i + 1)
            @test sum(b) == n - (i + 1) == sum(c)
        end
        #
        b = bitrand(n)
        t = deepcopy(b)
        rshift!(b, t, 0)
        @test b.chunks !== t.chunks
        for i in (1, 2, 3, 4, 5, 17, 24, 37, 63, 64, n, n + 1)
            rshift!(b, t, 0)
            rshift!(b, i)
            rshift!(c, t, i)
            @test sum(b) == sum(t[i+1:n]) == sum(c)
            @test b == rshift(t, i) == rshift(t, i)
        end
    end
    for n in (64, 65, 79, 127, 128, 129, 158, 191, 192, 193, 1023, 1024, 1025)
        b = trues(n)
        t = trues(n)
        c = similar(b)
        # push bits off one by one
        for i = n-1:-1:0
            lshift!(b, 1)
            lshift!(c, t, n-i)
            @test sum(b) == i == sum(c)
        end
        # place bit at left-most, then walk it to right-most, then back again
        b .= false
        b[end] = true
        for r = (-(n-1):1:-1, 2:1:n)
            for i = r
                lshift!(b, signbit(i) ? -1 : 1)
                @test b[abs(i)]
            end
        end
        lshift!(b, t, 0)
        @test all(b)
        @test b.chunks !== t.chunks
        for i in (1, 2, 3, 4, 5, 17, 24, 37, 63, 64)
            lshift!(b, t, 0)
            lshift!(b, i)
            lshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
        end
        for i = n-2:n
            lshift!(b, t, 0)
            lshift!(b, i)
            lshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
        end
        for i = 64:64:n-1
            lshift!(b, t, 0)
            lshift!(b, i)
            lshift!(c, t, i)
            @test sum(b) == n - i == sum(c)
            lshift!(b, t, 0)
            lshift!(b, i - 1)
            lshift!(c, t, i - 1)
            @test sum(b) == n - (i - 1) == sum(c)
            lshift!(b, t, 0)
            lshift!(b, i + 1)
            lshift!(c, t, i + 1)
            @test sum(b) == n - (i + 1) == sum(c)
        end
        #
        b = bitrand(n)
        t = deepcopy(b)
        lshift!(b, t, 0)
        @test b.chunks !== t.chunks
        for i in (1, 2, 3, 4, 5, 17, 24, 37, 63, 64, n, n + 1)
            lshift!(b, t, 0)
            lshift!(b, i)
            lshift!(c, t, i)
            @test sum(b) == sum(t[1:n-i]) == sum(c)
            @test b == (t >> i)
            @test b == lshift(t, i) == lshift(t, i)
        end
    end
end
