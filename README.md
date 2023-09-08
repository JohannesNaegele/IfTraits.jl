[![CI](https://github.com/JohannesNaegele/IfTraits.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JohannesNaegele/IfTraits.jl/actions/workflows/CI.yml) [![codecov](https://codecov.io/gh/JohannesNaegele/IfTraits.jl/graph/badge.svg?token=RQIJHHG9TP)](https://codecov.io/gh/JohannesNaegele/IfTraits.jl)

# IfTraits.jl

This lightweight package provides convenience macros for traits (similar to and inspired by [SimpleTraits.jl](https://github.com/mauro3/SimpleTraits.jl)). However, function behavior depending on traits can now be specified via intuitive `if`/`else` syntax using `@iftraits`.

## Disclaimer

This package is in an early stage of development; whether it's concept really is useful is not yet clear to me. Feel free to suggest features, improvements and (of course) bugfixes!

## Basic usage

Consider the example 
```julia
@traitdef IsNice
@traitimpl IsNice(Int)
@iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"
```
which (unsurprisingly) leads to 
```jlcon
@test f(5) == "Very nice!"
@test f(5.0) == "Not so nice!"
```

## Implementation

Internally, we just replace  `IsNice(x)` by a function call `trait{IsNice}(x)` and return `true` in the case of a fulfilled trait and `false` in the case of a missing trait. 
Because the compiler is smart, the return value of these functions gets detected at compile time and the trait dispatch does not have to be done at runtime.

## Main functionality

From this example the advantage over other packages is not apparent. The real power instead lies in the simplicity of defining functions which *depend on multiple types*.
As far as I know, usually the approach to this problem is either to use [combined traits](https://github.com/mauro3/SimpleTraits.jl/issues/71) (which in my opinion is not very intuitive) or to define a bunch of [different functions](https://github.com/mauro3/SimpleTraits.jl/pull/2) depending on several input traits (which imo is kinda messy).

In our case, this can be solved with generic syntax:
```
# dummy example
abstract type Musician end
struct OperaSinger<:Musician end
struct ChartsSinger<:Musician end
struct BadSinger<:Musician end
struct Composer<:Musician end

@traitdef CanSing, CanCompose
@traitimpl CanSing(OperaSinger, ChartsSinger)
@traitimpl CanCompose(Composer, ChartsSinger)
```
In this setting we ask whether it makes sense to have `a` compose something for `b`.
```julia
@iftraits function compose_for(a, b)
    if CanCompose(a)
        if CanSing(b)
            println("works")
        else
            println("compose for someone else")
        end
    elseif CanCompose(b)
        if CanSing(b)
            println("compose for yourself and save the money")
        else
            println("maybe you should change your job?")
        end
    else
        if CanSing(b)
            println("play Puccini then!")
        else
            println("wtf is this bullshit")
        end
    end
end
```
We get the intended behavior:
```
...
```
The generated functions are:
```
...
```

More examples can be found [here](./examples).

## Discussion

### Multitype traits
My current understanding is that special traits of the form `BelongTogether(X, Y)` are just a (more or less) natural extension. Let's say we have a function `ship` which we would like to formulate using traits.
```julia
struct Romeo end; struct Juliet end
belong_together(a, b) = false
belong_together(a::Romeo, b::Juliet) = true
belong_together(a::Juliet, b::Romeo) = true
ship(a, b) = belong_together(a, b) ? "go marry" : "nothing holds forever"
```

Now we can use the following trick:
```julia
# Multi is just a dummy trait, we could instead use an arbitrary type
@traitdef Multi, BelongTogether
@traitimpl BelongTogether(Multi)
# assume types X and X
function ⊕(a, b) end
⊕(::Romeo, ::Juliet) = Multi(); ⊕(::Juliet, ::Romeo) = Multi()
```

Thus, we can now write
```julia
ship(a, b) = @iftraits BelongTogether(⊕(a, b)) ? "go marry" : "nothing holds forever"
```
Note however that we need a different function `⊕` for every multi-type trait. This pattern could of course be simplified by some new feature (something along defining `struct ⊕{T} end` and extending `@traitdef`/`@traitimpl` macros.).

### Other
Obvious that we overwrite:
@traitfn fn(x::X) where {X<:AbstractFloat;  Tr{X}} = 2
@traitfn fn(x::X) where {X<:AbstractFloat; Tr2{X}} = 4

## Credit
Credit goes of course to Tim Holy (see [here](https://github.com/JuliaLang/julia/issues/2345#issuecomment-54537633) the THTT) and Mauro Werder. If you feel like the credit for your contribution is missing, don't hesitate to contact me.

## Other trait packages
If this package does not fit your use case, you might want to have a look at these packages:
- [SimpleTraits.jl](https://github.com/mauro3/SimpleTraits.jl) (and the deprecated [Traits.jl](https://github.com/mauro3/Traits.jl#dispatch-on-traits))
- [WhereTraits.jl](https://github.com/jolin-io/WhereTraits.jl)
- [CanonicalTraits.jl](https://github.com/thautwarm/CanonicalTraits.jl)
- [BinaryTraits.jl](https://github.com/tk3369/BinaryTraits.jl)

## Other resources

Here are some other helpful resources:

- [Official documentation regarding traits](https://docs.julialang.org/en/v1/manual/methods/#Trait-based-dispatch-1), it's imho kinda difficult to understand
- Tom Kwong's book [Hands-on design patterns and best practices with Julia: proven solutions to common problems in software design for Julia 1.x](https://www.packtpub.com/product/hands-on-design-patterns-and-best-practices-with-julia/9781838648817)
- Christopher Rackauckas' blog post [Type-Dispatch Design: Post Object-Oriented Programming for Julia](http://www.stochasticlifestyle.com/type-dispatch-design-post-object-oriented-programming-julia/)
- Frames Catherine White' blog post [The Emergent Features of JuliaLang: Part II - Traits](https://invenia.github.io/blog/2019/11/06/julialang-features-part-2/)
- GitHub repositories [Object Orientation and Polymorphism in Julia](https://github.com/ninjaaron/oo-and-polymorphism-in-julia) and [Dispatching Design Patterns](https://github.com/ninjaaron/dispatching-design-patterns) from Aaron Christianson
