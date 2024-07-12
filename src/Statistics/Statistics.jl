import Statistics
using Statistics: mean, median, quantile

# import StatsBase: weights
# weighted_mean(x, w) = mean(x, weights(w))
# weighted_sum(x, w) = sum(x, weights(w))

weighted_sum(x::AbstractVector, w::AbstractVector) = sum(x .* w)
weighted_mean(x::AbstractVector, w::AbstractVector) = sum(x .* w) / sum(w)


include("movmean.jl")
include("NanQuantile.jl")
include("match2.jl")


export weighted_mean, weighted_sum
export mean, median, quantile, movmean, weighted_movmean
export _nanquantile!, NanQuantile
