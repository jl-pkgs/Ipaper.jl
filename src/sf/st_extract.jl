function st_location((x, y)::Tuple{Real,Real};
  b::bbox, cellx::Real, celly::Real, nx::Int, ny::Int)

  i = (x - b.xmin) / cellx
  if celly > 0
    j = (y - b.ymin) / celly
  else
    j = (b.ymax - y) / abs(celly)
  end
  i = floor(Int, i)
  j = floor(Int, j)

  if (i < 1 || i > nx) || (j < 1 || j > ny)
    nothing
  else
    i, j
  end
end


"""
    st_location(r::Raster, points::Vector{Tuple{T,T}})

return the overlaping indexes `inds`, and corresponding (i,j)

# Examples
```julia
inds, locs = st_location(r, points)
```
"""
function st_location(ra::AbstractSpatRaster, points::Vector{Tuple{T,T}}) where {T<:Real}
  b = st_bbox(ra)
  nx, ny = size(ra)[1:2]
  cellx, celly = st_cellsize(ra)
  inds, locs = st_location.(points; b, cellx, celly, nx, ny) |> _rm_empty
  inds, locs
end

function _rm_empty(x::Vector)
  inds = findall(!isnothing, x)
  inds, x[inds]
end


function st_extract(ra::AbstractSpatRaster, points::Vector{Tuple{T,T}}; combine=hcat) where {T<:Real}
  inds, locs = st_location(ra, points)
  cols = repeat([:], ndims(ra) - 2)
  lst = [ra.A[i, j, cols...] for (i, j) in locs]
  inds, combine(lst...) #cbind(lst...)
end

export st_location, st_extract
