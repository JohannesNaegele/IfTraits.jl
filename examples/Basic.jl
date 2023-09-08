using .IfTraits
@traitdef IsNice
@traitimpl IsNice(Int)
@iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"

f(5)
f(5.0)

@iftraits f(x) = !IsNice(x) ? "Very nice!" : "Not so nice!"

f(5)
f(5.0)


@test f(5) == "Very nice!"
@test f(5.0) == "Not so nice!"

@code_native f(5)
@code_native f(5.0)

@traitimpl IsNice(String)
@iftraits foo(x) = IsNice(x) ? 2 : 0
f(5.0) == "Not so nice!"

@code_native foo("5")