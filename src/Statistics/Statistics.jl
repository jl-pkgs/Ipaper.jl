import Statistics
using Statistics: mean

include("quantile.jl")
include("movmean.jl")
include("apply.jl")
include("Vogel2020.jl")

export mean, movmean, weighted_mean, weighted_movmean
export apply
export nanquantile, Quantile
# quantile2, 
