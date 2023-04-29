# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper
# using Ipaper
# @reexport using Z: x, y
using DocStringExtensions: TYPEDSIGNATURES, METHODLIST

import Dates
# using Pipe
# using DimensionalData
# using DataFrames
# import CSV
# import Statistics: quantile

using Reexport
@reexport using NaNStatistics
@reexport using TimerOutputs: reset_timer!, @timeit

using Printf
export @sprintf

using LambdaFn
# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f

include("timeit_all.jl")
include("Pipe.jl")
@reexport using .Pipe

include("tools.jl")

include("cmd.jl")
include("tools_plot.jl")

include("dates.jl")
include("factor.jl")
include("file_operation.jl")
include("list.jl")
include("match2.jl")
include("par.jl")
include("stringr.jl")
# include("DimensionalData.jl")
include("missing.jl")
include("Statistics/Statistics.jl")
include("Climate/Climate.jl")

dim = size
# whos = varinfo

export dim

end
