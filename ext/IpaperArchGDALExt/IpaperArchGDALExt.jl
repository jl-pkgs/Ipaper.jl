export IpaperArchGDALExt
module IpaperArchGDALExt

export write_tiff

using DocStringExtensions: TYPEDSIGNATURES, METHODLIST

using ArchGDAL
using ArchGDAL.GDAL
using ArchGDAL.GDAL.GDAL_jll: gdalinfo_path, ogrinfo_path

using Ipaper.sf
import Ipaper.sf: write_gdal, read_gdal, gdalinfo, getgeotransform, 
  gdal_polygonize, nband, nlayer
# import Ipaper.sf: WGS84

include("gdal_basic.jl")
include("write_gdal.jl")
include("read_gdal.jl")
include("gdalinfo.jl")
include("gdal_polygonize.jl")

end
