import Statistics
using Statistics: mean

include("quantile.jl")
include("movmean.jl")
include("apply.jl")


export mean, movmean, weighted_mean, weighted_movmean
export apply
export quantile2, nanquantile, Quantile
