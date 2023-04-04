# Remove LineNumberNodes
function clean!(expr)
    if expr isa Expr
        filter!(x -> !(x isa LineNumberNode), expr.args)
        clean!.(expr.args)
    end
end

# Remove unnecessary begin/end or quote/end blocks
function remove_blocks!(expr)
    if expr isa Expr
        isblock(x) = (x isa Expr) && (x.head == :block)
        expr.args = [
            isblock(x) && length(x.args) == 1 ? x.args[1] : x
            for x in expr.args
        ]
        filter!(x -> !(isblock(x) && isempty(x.args)), expr.args)
        remove_blocks!.(expr.args)
    end
end