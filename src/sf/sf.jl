module sf


## add test data
const dir_data = "$(@__DIR__)/../../data"
const guanshan_dem = "$dir_data/GuanShan_dem250m.tif"
const guanshan_flowdir_cpp = "$dir_data/GuanShan_flowdir_cpp.tif"
const guanshan_flowdir_gis = "$dir_data/GuanShan_flowdir_gis.tif"
export guanshan_dem, guanshan_flowdir_cpp, guanshan_flowdir_gis


using ProgressMeter
using Ipaper: file_ext, obj_size, findnear
using Statistics: median

export bbox, in_bbox, bbox_overlap
export bbox2lims, 
  bbox2cellsize,
  bbox2range, bbox2vec,
  bbox2dims, bbox2ndim
export range2bbox
export st_points
export st_bbox, st_dims, st_cellsize, st_mosaic
export st_write, st_read, nlyr
export rm_shp
export getgeotransform
export read_sf, write_sf

export xy2ij, cellArea

# export gdal_polygonize, nband, nlayer
# export write_gdal, read_gdal
# export bandnames, set_bandnames
function read_sf end
function write_sf end

function nband end
function nlayer end
function gdal_polygonize end
function read_gdal end
function write_gdal end
function gdalinfo end
function gdal_info end
function ogr_info end
function bandnames end
function set_bandnames end

nlyr = nband
st_write = write_gdal
st_read = read_gdal

include("bbox.jl")
include("SpatRaster.jl")
include("Ops.jl")

include("st_bbox.jl")
include("st_dims.jl")
include("IO.jl")

include("st_extract.jl")
include("st_resample.jl")
include("st_mosaic.jl")

include("distance.jl")

function st_points(x::AbstractVector, y::AbstractVector)
  [(x[i], y[i]) for i in eachindex(x)]
end


function shp_files(f)
  [f,
    replace(f, ".shp" => ".shx"),
    replace(f, ".shp" => ".prj"),
    replace(f, ".shp" => ".dbf")]
end

function rm_shp(f)
  rm.(shp_files(f))
  nothing
end


## cell info
# b = st_bbox(f)
# cellx, celly = sf.gdalinfo(f)["cellsize"]
function xy2ij(x::T, y::T, b::bbox, cellsize) where {T<:Real}
  cellx, celly = cellsize
  i = floor(Int, (x - b.xmin) / cellx)
  if celly < 0
    j = floor(Int, (b.ymax - y) / abs(celly))
  else
    j = floor(Int, (y - b.ymin) / celly)
  end
  return i, j
end

function xy2ij(point::Tuple{T,T}, ra::SpatRaster) where {T<:Real}
  x, y = point
  xy2ij(x, y, st_bbox(ra), st_cellsize(ra))
end

# in km^2
function cellArea(x, y, cellsize)
  cellx, celly = cellsize
  dx = earth_dist((x, y), (x + cellx, y))
  dy = earth_dist((x, y), (x, y + celly))
  return dx * dy
end


end
