function _rm_empty(x::Vector)
  inds = findall(!isnothing, x)
  inds, x[inds]
end

function _is_empty(locs::Vector)
  isempty = map(p -> (p[1] != -1 && p[2] != -1), locs) # 有一个为-1就是空
  isempty, locs
end

function st_location_exact(lon::AbstractVector, lat::AbstractVector, points::Vector{Tuple{T,T}}) where {T<:Real}
  cellx, celly = st_cellsize(lon, lat)
  map(p -> findnear(p, lon, lat; cellx, celly), points)
end


"""
    st_location(r::Raster, points::Vector{Tuple{T,T}})

return the overlaping indexes `inds`, and corresponding (i,j)

# Examples
```julia
inds, locs = st_location(r, points)
```
"""
function st_location(lon::AbstractVector, lat::AbstractVector, points::Vector{Tuple{T,T}}) where {T<:Real}
  b = st_bbox(lon, lat)
  nx, ny = length(lon), length(lat)
  cellx, celly = st_cellsize(lon, lat)
  _location_fast.(points; b, cellx, celly, nx, ny)
end

function _location_fast((x, y)::Tuple{Real,Real};
  b::bbox, cellx::Real, celly::Real, nx::Int, ny::Int)

  i = (x - b.xmin) / cellx
  if celly > 0
    j = (y - b.ymin) / celly
  else
    j = (b.ymax - y) / abs(celly)
  end

  i2 = floor(Int, i) + 1
  j2 = ceil(Int, j)
  # @show x, y, i, j, i2, j2 # 存在的问题就是最后一个匹配不上
  if (i2 < 1 || i2 > nx) || (j2 < 1 || j2 > ny)
    return nothing
  else
    i2, j2
  end
end

function st_location(ra::AbstractSpatRaster, points::Vector{Tuple{T,T}}) where {T<:Real}
  lon, lat = st_dims(ra)
  st_location(lon, lat, points)
end


function st_extract(ra::AbstractSpatRaster, points::Vector{Tuple{T,T}}; combine=hcat) where {T<:Real}
  inds, locs = st_location(ra, points) |> _rm_empty
  cols = repeat([:], ndims(ra) - 2)
  lst = [ra.A[i, j, cols...] for (i, j) in locs]
  inds, combine(lst...) #cbind(lst...)
end


export st_location, st_location_exact
export st_extract
