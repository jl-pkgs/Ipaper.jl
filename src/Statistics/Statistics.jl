import Statistics
using Statistics: mean, median

include("linreg.jl")
include("movmean.jl")
include("apply.jl")
include("NanQuantile.jl")


export mean, median, quantile, movmean, weighted_mean, weighted_movmean
export apply
export _nanquantile!, nanquantile, NanQuantile
export lm, linreg, linreg_fast, linreg_simple
