import Statistics
using Statistics: mean, median, quantile

# import StatsBase: weights
# weighted_mean(x, w) = mean(x, weights(w))
# weighted_sum(x, w) = sum(x, weights(w))
include("match2.jl")
include("approx.jl")
include("movmean.jl")
include("movstd.jl")
include("NaNStatistics.jl")
include("Quantile/NanQuantile.jl")

export weighted_sum, weighted_nansum
export weighted_mean, weighted_nanmean

export mean, median, quantile, movmean, weighted_movmean
export _nanquantile!, NanQuantile
