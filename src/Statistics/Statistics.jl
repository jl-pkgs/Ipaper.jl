import Statistics
using Statistics: mean, median

include("movmean.jl")
include("NanQuantile.jl")


export mean, median, quantile, movmean, weighted_mean, weighted_movmean
export _nanquantile!, NanQuantile
