# based on Frames Catherine White's blog post at https://invenia.github.io/blog/2019/11/06/julialang-features-part-2/

@traitdef IsContinuous, IsOrdinal, IsCategorical, IsNormable
@traitimpl IsContinuous(Type{<:AbstractFloat})
@traitimpl IsOrdinal(Type{<:Integer})
@traitimpl IsCategorical(Type{<:Bool})
@traitimpl IsCategorical(Type{<:AbstractString})
@traitimpl IsNormable(Type{<:Complex})

using LinearAlgebra
@iftraits function bounds(xs::AbstractVector{T}) where {T}
    if IsCategorical(T)
        return unique(xs)
    elseif IsNormable(T)
        return maximum(norm.(xs))
    elseif IsOrdinal(T) || IsContinuous(T)
        return extrema(xs)
    end
end

bounds([false, false, true])
bounds([false, false, false])
bounds([1, 2, 3, 2])
bounds([1 + 1im, -2 + 4im, 0 - 2im])