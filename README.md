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

## Discussion

This approach has the (unintended but not unwelcome) side effect of easily detecting and eliminating function disambiguities. Since traits are not allowed to change their hierarchy within a function, this generates a error message:
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
Moreover, we don't need to define a general hierarchy between traits, since this is only necessary within and can be different for each function. This is different from e.g. ???.

