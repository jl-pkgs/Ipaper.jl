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


# This symbol is only defined on Julia versions that support extensions.
@static if !isdefined(Base, :get_extension)
  using Requires
end


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
include("IO.jl")

include("precompile.jl")
dim = size
export dim
# whos = varinfo


# Compatibility with pre-1.9 julia
function __init__()
  @static if !isdefined(Base, :get_extension)
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("tools_plot.jl")
  end
end


end
