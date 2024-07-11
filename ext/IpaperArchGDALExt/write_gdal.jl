## This part is borrowed from the GeoArrays.jl package.
# MIT License, Copyright (c) 2018 Maarten Pronk
# <https://github.com/evetion/GeoArrays.jl/blob/master/src/io.jl>

# using GeoFormatTypes, ArchGDAL
# WGS84 = convert(WellKnownText, EPSG(4326))
# GFT.val(ga.crs)
const WGS84 = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"

# copied from `GeoArrays`
const gdt_conversion = Dict{DataType,DataType}(
  Bool => UInt8,
  Int8 => UInt8,
  UInt64 => UInt32,
  Int64 => Int32
)

"""Converts type of Array for one that exists in GDAL."""
function cast_to_gdal(A::AbstractArray{<:Real})
  type = eltype(A)
  if type in keys(gdt_conversion)
    newtype = gdt_conversion[type]
    @warn "Casting $type to $newtype to fit in GDAL."
    return newtype, convert(Array{newtype}, A)
  else
    error("Can't cast $(eltype(A)) to GDAL.")
  end
end

const OPTIONS_DEFAULT_TIFF = Dict(
  # "BIGTIFF" => "YES"
  "TILED" => "YES", # not work
  "COMPRESS" => "DEFLATE"
)

function write_gdal(ra::AbstractSpatRaster, f::AbstractString;
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

# # Slice data and replace missing by nodata
# if isa(dtype, Union) && dtype.a == Missing
#   dtype = dtype.b
#   try
#     convert(ArchGDAL.GDALDataType, dtype)
#   catch
#     dtype, data = cast_to_gdal(data)
#   end
#   nodata === nothing && (nodata = typemax(dtype))
#   m = ismissing.(data)
#   data[m] .= nodata
#   data = Array{dtype}(data)
#   use_nodata = true
# end
