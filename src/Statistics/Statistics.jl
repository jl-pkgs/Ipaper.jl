import Statistics
using Statistics: mean, median

include("movmean.jl")
include("apply.jl")
include("NanQuantile.jl")


export mean, median, quantile, movmean, weighted_mean, weighted_movmean
export apply
export _nanquantile!, nanquantile, NanQuantile
