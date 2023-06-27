import Statistics
using Statistics: mean

include("linreg.jl")
include("movmean.jl")
include("apply.jl")
include("NanQuantile.jl")


export mean, movmean, weighted_mean, weighted_movmean
export apply
export _nanquantile!, nanquantile, NanQuantile,NanQuantile_low, NanQuantile_low!
export lm, linreg, linreg_fast, linreg_simple
