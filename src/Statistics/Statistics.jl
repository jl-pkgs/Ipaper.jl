import Statistics
using Statistics: mean

include("missing.jl")
include("quantile.jl")
include("quantile_nd.jl")

include("movmean.jl")
include("apply.jl")
include("Vogel2020.jl")

export mean, movmean, weighted_mean, weighted_movmean
export apply
export nanquantile, Quantile, quantile!
