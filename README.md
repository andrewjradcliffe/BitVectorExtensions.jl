# BitVectorExtensions

## Installation
```julia
using Pkg
Pkg.add("BitVectorExtensions")
```

## Description

This [PR](https://github.com/JuliaLang/julia/pull/45728) as a
standalone.  The constructor from `Unsigned` exhibits type piracy, so
beware.

Preface: there are two distinct concepts here -- a constructor for
`BitVector` from unsigned integers, and `l/r-shift[!]` methods which
match the corresponding shifts on bit indices. These methods may be
useful if you find the motivation (or need) to work with raw bits,
then later wish to use these raw bits as indices, in which case the
most natural abstraction is a `BitVector`. 

Admittedly a niche application (from the perspective of those
fortunate souls not forced into bit-twiddling by pure efficiency
concerns), but why roll your own abstraction over raw bits when `Base`
provides such a rich interface with well-tested methods? Or, perhaps
someone seeking to store the contents of a `BitVector` in a text
format.
