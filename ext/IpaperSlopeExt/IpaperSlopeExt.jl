export IpaperSlopeExt
module IpaperSlopeExt


using Statistics: mean, median, quantile
using StatsBase: cov, var, autocor, tiedrank
using Distributions: ccdf, Normal, TDist, cdf


sqrt2(x) = x < 0 ? NaN : sqrt(x)
pnorm(z) = cdf(Normal(), z)
pt(x, df::Int) = cdf(TDist(df), x)


using Ipaper
import Ipaper: lm_resid, slope_mk, slope_p


include("slope_mk.jl")
include("slope_p.jl")

end
