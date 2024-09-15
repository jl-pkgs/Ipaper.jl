"""
    st_mosaic(rs::Vector{SpatRaster{T,N}}; kw...) where {T,N}

# Arguments
- `kw`: others to `SpatRaster`
"""
function st_mosaic(rs::Vector{SpatRaster{T,N}}; kw...) where {T,N}
  ra = rs[1]
  # missingval = T(missingval)
  cellsize = st_cellsize(ra)
  box = st_bbox(st_bbox.(rs))
  lon2, lat2 = bbox2dims(box; cellsize)

  _size = length(lon2), length(lat2)
  nd = ndims(ra)
  cols = repeat([:], nd - 2)

  nd >= 3 && (_size = (_size..., size(ra)[3:end]...))
  A = zeros(T, _size)

  # 这里不能使用并行
  # Threads.@threads 
  for i in eachindex(rs)
    ra = rs[i]
    b = st_bbox(ra)
    ilon, ilat = bbox_overlap(b, box; cellsize)
    A[ilon, ilat, cols...] .= ra.A
  end
  
  (; bands, time, name) = ra
  SpatRaster(A, box; bands, time, name, kw...)
end
