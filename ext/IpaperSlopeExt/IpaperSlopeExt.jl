export IpaperSlopeExt
module IpaperSlopeExt


using Statistics: mean, median, quantile
using StatsBase: autocor, tiedrank
using Distributions: ccdf, Normal

using Ipaper
using Ipaper: lm_resid, slope_mk, slope_p, mkTrend

include("mkTrend.jl")
include("slope_fun.jl")

end
