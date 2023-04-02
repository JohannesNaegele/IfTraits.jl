# Multi is just a dummy trait, we could instead use an arbitrary type
@traitdef Multi, BelongTogether
@traitimpl BelongTogether(Multi)
# assume types X and X
function ⊕(a, b) end; ⊕(::Int, ::Float64) = Multi()
@iftraits ship(a, b) = BelongTogether(a ⊕ b) ? "go marry" : "nothing holds forever"
ship(1, 1.0)
ship(1, 1)