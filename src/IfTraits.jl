module IfTraits

export Trait,  @traitdef, @traitrm, @traitimpl, @iftraits

include("Helpers.jl")

abstract type Trait end
struct trait{T} end

const traits_collection = Set([])

macro traitdef(expr)
    result = quote end
    function add_symbol(symb)
        push!(traits_collection, symb)
        push!(result.args, :(struct $(symb) <: Trait end))
    end
    add_default(symb) = push!(result.args, :(IfTraits.trait{$(symb)}(x) = false))
    if expr isa Symbol
        add_symbol(expr)
        add_default(expr)
    else
        for trait in expr.args
            add_symbol(trait)
            add_default(trait)
        end
    end
    esc(result)
end

macro traitrm(expr)
    function remove_symbol(symb)
        pop!(traits_collection, symb)
    end
    if expr isa Symbol
        remove_symbol(expr)
        remove_symbol
        for trait in expr.args
            remove_symbol(trait)
        end
    end
    esc(result)
end

macro traitimpl(expr)
    result = quote end
    @assert (expr.head == :call)
    trait = expr.args[1]
    for arg in expr.args[2:end]
        push!(result.args, :(IfTraits.trait{$(trait)}(::$(arg)) = true))
        # push!(result.args, :(trait{$(trait)}(::Type{<:$(arg)}) = true))
    end
    esc(result)
end

function rewrite_traits!(expr)
    if expr isa Expr
        # maybe considering LineNumberNodes is unnecessary here
        func_name_index = findfirst(x -> !(x isa LineNumberNode), expr.args);
        if (expr.head == :call) && (func_name = expr.args[func_name_index]; func_name in traits_collection)
            old_args = deepcopy(expr.args[func_name_index+1:end])
            expr.head = :block
            expr.args = [:(IfTraits.trait{$(func_name)}($(old_args...)))] # isa Type(<:$(func_name)())
        end
        for arg in expr.args
            rewrite_traits!(arg)
        end
    end
end

macro iftraits(expr)
    rewrite_traits!(expr)
    remove_blocks!(expr)
    return esc(expr)
end

end # module IfTraits