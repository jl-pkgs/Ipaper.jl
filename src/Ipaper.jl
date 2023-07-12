# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper
# using Ipaper
using Reexport
@reexport using DocStringExtensions: TYPEDSIGNATURES, METHODLIST

import Dates
# using Pipe
# using DimensionalData

# This symbol is only defined on Julia versions that support extensions
if !isdefined(Base, :get_extension)
using Requires
end

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

include("missing.jl")
include("Statistics/Statistics.jl")
include("Climate/Climate.jl")

include("precompile.jl")
include("tools_plot.jl")

dim = size
export dim
# whos = varinfo


# Compatibility with pre-1.9 julia
function __init__()
  @static if !isdefined(Base, :get_extension)
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("../ext/PlotExt.jl")
  end
end


end
