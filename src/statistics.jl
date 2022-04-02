import Statistics
include("quantile.jl")

# import Statistics: quantile, quantile!, _quantile, require_one_based_indexing

function Quantile(array::AbstractArray{<:Real}, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  mapslices(x -> quantile2(x, probs), array, dims = dims)
end

function Quantile(array::AbstractNanArray, probs=[0, 0.25, 0.5, 0.75, 1]; dims=1)
  mapslices(x -> begin
    ans = quantile2(skipmissing(x), probs)
  end, array, dims=dims)
end

# `dims`: symbol
"""
  Quantile(array::AbstractArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  
# Examples
```julia
arr = rand(200, 200, 365);
d = DimArray(arr, ["lon", "lat", "time"]);
probs = [0.5, 0.9];
Quantile(d, probs; dims = :time)
```
"""
function Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  # dims = dimnum2(array, dims)
  if eltype(dims) <: Integer; dims = name(da.dims)[dims]; end
  if dims isa String; dims = Symbol(dims); end

  bands = collect(name(da.dims))
  r = mapslices(x -> quantile(x, probs), da, dims = dims)
  r = DimArray(r.data, bands) # dimension error, rebuild it
  set(r, dims => :prob)
end



# function Statistics._quantilesort!(v::Vector{Union{}}, sorted::Bool, minp::Real, maxp::Real) 
#   # isempty(v) && return([])
#   return v;
#   # Vector{Union{}}[]
# end




# # Function to perform partial sort of v for quantiles in given range
# function Statistics._quantilesort!(v::AbstractArray, sorted::Bool, minp::Real, maxp::Real)
#     isempty(v) && return([]) #throw(ArgumentError("empty data vector"))
#     Statistics.require_one_based_indexing(v)

#     if !sorted
#         lv = length(v)
#         lo = floor(Int,minp*(lv))
#         hi = ceil(Int,1+maxp*(lv))

#         # only need to perform partial sort
#         sort!(v, 1, lv, Base.Sort.PartialQuickSort(lo:hi), Base.Sort.Forward)
#     end
#     if (sorted && (ismissing(v[end]) || (v[end] isa Number && isnan(v[end])))) ||
#         any(x -> ismissing(x) || (x isa Number && isnan(x)), v)
#         throw(ArgumentError("quantiles are undefined in presence of NaNs or missing values"))
#     end
#     return v
# end

export quantile, Quantile
