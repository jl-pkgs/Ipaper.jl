# using PooledArrays
# factor = PooledArray
using CategoricalArrays: CategoricalArray, CategoricalValue, levels, compress


factor(args...) = CategoricalArray(args...) |> compress

factor_value(x::CategoricalValue) = levels(x)[x.ref]
factor_value(x::CategoricalArray) = factor_value.(x)

export factor, factor_value, CategoricalArrays


precompile(factor, (Vector{Float64},))

export levels
