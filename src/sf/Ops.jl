# https://gdal.org/tutorials/geotransforms_tut.html
function getgeotransform(ra::AbstractSpatRaster)
  x, y = st_dims(ra)
  
  cellx, celly = st_cellsize(ra)
  y0 = y[1] - celly / 2
  x0 = x[1] - cellx / 2
  [x0, cellx, 0, y0, 0, celly]
end
