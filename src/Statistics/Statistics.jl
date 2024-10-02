import Statistics
using Statistics: mean, median, quantile

# import StatsBase: weights
# weighted_mean(x, w) = mean(x, weights(w))
# weighted_sum(x, w) = sum(x, weights(w))

include("movmean.jl")
include("NanQuantile.jl")
include("match2.jl")
include("weighted_nansum.jl")
include("weighted_nanmean.jl")

export weighted_sum, weighted_nansum
export weighted_mean, weighted_nanmean

export mean, median, quantile, movmean, weighted_movmean
export _nanquantile!, NanQuantile
