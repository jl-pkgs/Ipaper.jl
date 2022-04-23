# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper
# using Ipaper
# @reexport using Z: x, y

using Dates
using Pipe
using LambdaFn
using DimensionalData
using Plots: plot!, savefig
# import Statistics: quantile

using Reexport
Reexport.@reexport using NaNStatistics

using Printf
export @sprintf

# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f

include("missing.jl")
include("plyr.jl")
include("cmd.jl")
include("dates.jl")
include("file_operation.jl")
include("par.jl")
include("stringr.jl")
include("tools.jl")
include("factor.jl")
include("data.frame.jl")
include("DimensionalData.jl")
include("statistics.jl")

dim = size
# whos = varinfo

export dim
export @pipe

end
