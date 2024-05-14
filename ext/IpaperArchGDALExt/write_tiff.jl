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

function write_tiff(ra::AbstractSpatRaster, f::AbstractString;
  nodata=nothing, options=String[], NUM_THREADS=4, BIGTIFF=true, proj::String=WGS84)

  data = ra.A
  dtype = eltype(data)
  shortname = find_shortname(f)
  driver = ArchGDAL.getdriver(shortname)
  width, height, nbands = size(ra)

  if (shortname == "GTiff")
    options = [options..., "COMPRESS=DEFLATE", "TILED=YES", "NUM_THREADS=$NUM_THREADS"]
    BIGTIFF && (options = [options..., "BIGTIFF=YES"])
  end

  try
    convert(ArchGDAL.GDALDataType, dtype)
  catch
    dtype, data = cast_to_gdal(data)
  end

  ArchGDAL.create(f; driver, width, height, nbands, dtype, options) do dataset
    for i = 1:nbands
      band = ArchGDAL.getband(dataset, i)
      ArchGDAL.write!(band, data[:, :, i])
      !isnothing(nodata) && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
    end

    # Set geotransform and crs
    ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, getgeotransform(ra))
    ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, proj)
  end
  ra.bands !== nothing && set_bandnames(f, ra.bands)
  f
end
