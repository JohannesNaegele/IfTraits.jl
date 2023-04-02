@traitdef IsNice
@traitimpl IsNice(Int)
@iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"

@test f(5) == "Very nice!"
@test f(5.0) == "Not so nice!"

@code_native f(5)
@code_native f(5.0)

@traitimpl IsNice(String)
@iftraits foo(x) = IsNice(x) ? 2 : 0
# bar(x) = (x isa Int) || (x isa String) ? 2 : 0

@code_native foo("5")
# @code_native bar("5")
# using BenchmarkTools
# @btime foo(5)
# @btime bar(5)