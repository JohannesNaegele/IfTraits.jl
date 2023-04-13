# based on Frames Catherine White's blog post at https://invenia.github.io/blog/2019/11/06/julialang-features-part-2/

@traitdef IsList
@traitimpl IsList(Type{<:AbstractVector}, Type{<:Tuple})

@iftraits aslist(x::T) where {T} = IsList(T) ? x : [x]

aslist(1)
aslist([1, 2, 3])
aslist([1])
aslist((1, 2, 3))