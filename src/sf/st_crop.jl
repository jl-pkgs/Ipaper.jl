export st_crop

st_crop(f::String, b::bbox) = read_gdal(f, b)

function st_crop(ra::SpatRaster, b::bbox)
  (; name, time, nodata, bands) = ra
  box = st_bbox(ra)
  cellsize = st_cellsize(ra)
  ix, iy = bbox_overlap(b, box; cellsize, reverse_lat=true)
  
  A = ra.A
  cols = repeat([:], ndims(A) - 2)
  data = A[ix, iy, cols...]
  rast(data, b; name, time, nodata, bands)
end
