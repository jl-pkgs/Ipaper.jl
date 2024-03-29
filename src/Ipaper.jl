# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper

import Dates
# using Ipaper

using Reexport
@reexport using DocStringExtensions: TYPEDSIGNATURES, METHODLIST
@reexport using ProgressMeter

include("Pipe.jl")
@reexport using .Pipe: @pipe

# using DimensionalData
# @reexport using NaNStatistics

# @reexport using TimerOutputs: reset_timer!, @timeit
# include("timeit_all.jl")

using Printf
export @sprintf

using LambdaFn
# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f


include("tools.jl")
include("IO.jl")
include("match2.jl")

include("file_operation.jl")
include("cmd.jl")
include("aria2c.jl")
include("main_cdo.jl")

include("dates.jl")
include("factor.jl")
include("list.jl")
include("par.jl")
include("par_mapslices.jl")
include("stringr.jl")

include("missing.jl")
include("Statistics/Statistics.jl")
include("Climate/Climate.jl")
include("Slope/Slope.jl")
include("sf/sf.jl")

include("precompile.jl")
include("tools_plot.jl")

include("apply.jl")


dim = size
export dim
# whos = varinfo

end
