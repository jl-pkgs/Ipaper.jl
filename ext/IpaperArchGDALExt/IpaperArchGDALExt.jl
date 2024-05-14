export IpaperArchGDALExt
module IpaperArchGDALExt

export write_tiff

using DocStringExtensions: TYPEDSIGNATURES, METHODLIST

using ArchGDAL
using ArchGDAL.GDAL
using ArchGDAL.GDAL.GDAL_jll: gdalinfo_path, ogrinfo_path

using Ipaper.sf
import Ipaper.sf: write_tiff, read_gdal, gdalinfo, getgeotransform
import Ipaper.sf: WGS84

include("write_tiff.jl")
include("read_gdal.jl")
include("gdalinfo.jl")
include("gdal_polygonize.jl")


# const drivers = AG.listdrivers()
const shortnames = Dict(
  (".tif", ".tiff") => "GTiff",
  (".nc", ".nc4") => "netCDF",
  (".img",) => "HFA",
  (".xyz",) => "XYZ",
  (".shp",) => "ESRI Shapefile",
  (".geojson",) => "GeoJSON",
  (".fgb",) => "FlatGeobuf",
  (".gdb",) => "OpenFileGDB",
  (".gml",) => "GML",
  (".gpkg",) => "GPKG"
)

## corresponding functions
function find_shortname(fn::AbstractString)
  _, ext = splitext(fn)
  for (k, v) in shortnames
    if ext in k
      return v
    end
  end
  error("Cannot determine GDAL Driver for $fn")
end


gdal_close(ds::Ptr{Nothing}) = GDAL.gdalclose(ds)

# gdal_open(file::AbstractString) = ArchGDAL.read(file)
function gdal_open(f::AbstractString, mode=GDAL.GA_ReadOnly, args...)
  GDAL.gdalopen(f, mode, args...)
end

function gdal_open(func::Function, args...; kwargs...)
  ds = gdal_open(args...; kwargs...)
  try
    func(ds)
  finally
    gdal_close(ds)
  end
end

function nband(f)
  gdal_open(f) do ds
    GDAL.gdalgetrastercount(ds)
  end
end

function bandnames(f)
  n = nband(f)
  gdal_open(f) do ds
    map(iband -> begin
        band = GDAL.gdalgetrasterband(ds, iband)
        GDAL.gdalgetdescription(band)
      end, 1:n)
  end
end

# works
function set_bandnames(f, bandnames)
  n = nband(f)
  gdal_open(f, GDAL.GA_Update) do ds
    map(iband -> begin
        band = GDAL.gdalgetrasterband(ds, iband)
        GDAL.gdalsetdescription(band, bandnames[iband])
      end, 1:n)
  end
  nothing
end


end
