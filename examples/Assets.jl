# Example from Tom Kwong's fantastic book Hands-on Design Patterns and Best Practices with Julia
abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

struct Residence <: House
    location::Any
end

struct Stock <: Equity
    symbol::Any
    name::Any
end

struct TreasuryBill <: FixedIncome
    cusip::Any
end

struct Money <: Cash
    currency::Any
    amount::Any
end

# abstract type LiquidityStyle end
# struct IsLiquid <: LiquidityStyle end
# struct IsIlliquid <: LiquidityStyle end

@iftraits marketprice(x) =
    IsLiquid(x) ? error("Please implement pricing function for", typeof(x)) :
    error("Price for illiquid asset $x is not available.")
