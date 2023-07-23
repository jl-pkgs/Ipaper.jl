export IpaperSlopeExt
module IpaperSlopeExt


using Statistics: mean, median, quantile
using StatsBase: autocor, tiedrank
using Distributions: ccdf, Normal

using Ipaper
using Ipaper: lm_resid
# , trend_mk

include("mktrend.jl")

end
