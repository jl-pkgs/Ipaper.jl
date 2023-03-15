# Copyright (c) 2022 Dongdong Kong. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

module Ipaper
# using Ipaper
# @reexport using Z: x, y
using DocStringExtensions: TYPEDSIGNATURES

import Dates
# using Pipe
# using DimensionalData
# using DataFrames
# import CSV
# import Statistics: quantile

using Reexport
@reexport using NaNStatistics

using Printf
export @sprintf

using LambdaFn
# rename to @f
@eval const $(Symbol("@f")) = $(Symbol("@λ"))
export @λ, @lf, @f

include("Pipe.jl")
@reexport using .Pipe

include("cmd.jl")
include("dates.jl")
include("factor.jl")
include("file_operation.jl")
include("list.jl")
include("match2.jl")
include("par.jl")
include("stringr.jl")
include("tools.jl")
# include("data.frame.jl")
# include("subset.jl")
# include("con_parse.jl")
# include("DimensionalData.jl")
include("Statistics/Statistics.jl")

dim = size
# whos = varinfo

export dim

end
