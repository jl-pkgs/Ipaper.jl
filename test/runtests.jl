using Test
using Ipaper

# println(dirname(@__FILE__))
# println(pwd())
# cd(dirname(@__FILE__)) do
import NaNStatistics
using Ipaper: NanQuantile_low, NanQuantile_low!

using ArchGDAL
include("sf/test_sf.jl")

using Distributions
include("test-slope.jl")

## Ipaper
include("test-par.jl")
include("test-Ipaper.jl")
include("test-missing.jl")
include("test-Pipe.jl")
include("test-string.jl")
include("test-list.jl")
include("test-date.jl")
include("test-r_base.jl")
include("test-tools.jl")

include("test-stat_quantile.jl")
include("test-stat_linreg.jl")
include("test-stat_apply.jl")
include("test-stat_movmean.jl")
