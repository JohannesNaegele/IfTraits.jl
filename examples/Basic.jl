# easiest example
@traitdef IsNice
@traitimpl IsNice(Int)
@iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"

f(5)
f(5.0)

# negation works
@iftraits f(x) = !IsNice(x) ? "Very nice!" : "Not so nice!"

f(5)
f(5.0)

# Julia compiles out redundant lines of code
@iftraits f(x) = !IsNice(x) ? 1 : 0

@code_llvm f(5)
@code_native f(5.0)