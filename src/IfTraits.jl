module IfTraits

export Trait, @traitdef, @traitimpl, @iftraits

include("Helpers.jl")

abstract type Trait end
struct trait{T} end

macro traitdef(expr)
    result = quote end
    function add_symbol(symb)
        push!(traits_collection, symb)
        push!(result.args, :(struct $(esc(symb)) <: Trait end))
    end
    if expr isa Symbol
        add_symbol(expr)
    else
        for trait in expr.args
            add_symbol(trait)
        end
    end
    result
end

macro traitimpl(expr)
    result = quote end
    @assert (expr.head == :call)
    trait = expr.args[1]
    push!(result.args, :(trait{$(trait)}(x) = false))
    for arg in expr.args[2:end]
        push!(result.args, :(trait{$(trait)}(::$(arg)) = true))
    end
    esc(result)
end

const traits_collection = Set([])
push!(traits_collection, :IsNice)

function rewrite_traits!(expr)
    if expr isa Expr
        # maybe considering LineNumberNodes is unnecessary here
        func_name_index = findfirst(x -> !(x isa LineNumberNode), expr.args);
        if (expr.head == :call) && (func_name = expr.args[func_name_index]; func_name in traits_collection)
            old_args = deepcopy(expr.args[func_name_index+1:end])
            expr.head = :block
            expr.args = [:(trait{$(func_name)}($(old_args...)))] # isa Type(<:$(func_name)())
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