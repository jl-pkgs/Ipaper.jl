
function Quantile(array::AbstractArray{<:Real}, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  mapslices(x -> quantile(x, probs), array, dims = dims)
end

function Quantile(array::AbstractNanArray, probs=[0, 0.25, 0.5, 0.75, 1]; dims=1)
  mapslices(x -> quantile(skipmissing(x), probs), array, dims=dims)
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


export quantile, Quantile
