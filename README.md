# IfTraits.jl

This package provides convenience macros for traits (similar to and inspired by [SimpleTraits.jl](https://github.com/mauro3/SimpleTraits.jl)). However, function behavior depending on traits can now be specified via intuitive `if`/`else` syntax using `@iftraits`. 

## Disclaimer

This package is in a very early stage of development and thus not ready for production yet. Feel free to suggest features, improvements and (of course) bugfixes!

## Basic usage

Consider the example 
```
@traitdef IsNice
@traitimpl IsNice(Int)
@iftraits f(x) = IsNice(x) ? "Very nice!" : "Not so nice!"
```
which (unsurprisingly) leads to 
```
@test f(5) == "Very nice!"
@test f(5.0) == "Not so nice!"
```

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
```
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

More examples can be found [here](./src/Examples.jl).

## Discussion

### Trait hierarchy

This approach has the (unintended but not unwelcome) side effect of easily detecting and eliminating function disambiguities. Since traits are not allowed to (1) be nested in itself or (2) change their hierarchy within a function, this generates a error message:
```
@iftraits function problem(a)
    if CanX(a)
        if CanY(a)
            nothing
        end
    end
    if CanY(a)
        if CanX(a)
            nothing
        end
    end
end
```
Moreover, we don't need to define a general hierarchy between traits, since this is only necessary within and can be distinct for each function.

### Multitype traits
My current understanding is that special traits of the form `BelongTogether(X, Y)` are just a natural extension. Let's say we have a function
```
ship(a, b) = BelongTogether(a, b) ? "go marry" : "nothing holds forever"
```
which should differentiate at compile time.

Now we can use the following trick: We define a new trait `@traitdef BelongTogether` with `@traitimpl BelongTogether(Bool)` and for types `X` and `Y` we can just define a new function `belong_together(a::X, b::Y) = true` and default behavior `belong_together(a, b) = nothing`.

Thus, we can now write
```
ship(a, b) = @iftraits BelongTogether(belong_together(a, b)) ? "go marry" : "nothing holds forever"
```
I am not shure whether this pattern should maybe made easier through some new feature.

## Credit
Credit goes of course to Tim Holy (see [here](https://github.com/JuliaLang/julia/issues/2345#issuecomment-54537633) the THTT) and Mauro Werder.