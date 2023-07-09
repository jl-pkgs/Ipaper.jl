using Test
using Ipaper
using Ipaper: NanQuantile_low, NanQuantile_low!
# println(dirname(@__FILE__))
# println(pwd())

# cd(dirname(@__FILE__)) do

include("test-Ipaper.jl")
include("test-missing.jl")
include("test-Pipe.jl")
include("test-string.jl")
include("test-list.jl")
include("test-date.jl")
include("test-r_base.jl")
include("test-timeit_all.jl")

include("test-stat_linreg.jl")
include("test-stat_quantile.jl")
include("test-stat_apply.jl")
include("test-stat_movmean.jl")
include("test-stat_anomaly.jl")
include("test-stat_threshold.jl")
include("test-stat_warmingLevel.jl")
# end
