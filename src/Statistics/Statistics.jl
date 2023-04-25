import Statistics
using Statistics: mean

include("NanQuantile.jl")

include("movmean.jl")
include("apply.jl")
include("Vogel2020.jl")
include("linreg.jl")


export mean, movmean, weighted_mean, weighted_movmean
export apply
export _nanquantile!, nanquantile, nanQuantile,NanQuantile, NanQuantile!
export lm, linreg_fast, linreg_simple
