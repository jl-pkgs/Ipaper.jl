module sf

using Ipaper: file_ext, obj_size

export bbox, in_bbox, bbox_overlap
export bbox2lims, 
  bbox2cellsize,
  bbox2range, bbox2vec,
  bbox2dims, bbox2ndim
export range2bbox
export st_bbox, st_dims, st_cellsize
export st_write, st_read, nlyr
export rm_shp
export getgeotransform
# export gdal_polygonize, nband, nlayer
# export write_gdal, read_gdal
# export bandnames, set_bandnames
function nband end
function nlayer end
function gdal_polygonize end
function read_gdal end
function write_gdal end
function gdal_info end
function org_info end
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
include("read_gdal.jl")
include("st_extract.jl")
include("st_resample.jl")


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


end
