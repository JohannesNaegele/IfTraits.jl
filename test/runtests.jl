using Test
using IfTraits

@testset "IfTraits.jl" begin
    @traitdef IsNice
    @traitimpl IsNice(Int)
    @iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"
    @test f(5) == "Very nice!"
    @test f(5.0) == "Not so nice!"
end