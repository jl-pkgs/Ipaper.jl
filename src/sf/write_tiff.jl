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
    # return newtype, 
    return convert(Array{newtype}, A)
  else
    error("Can't cast $(eltype(A)) to GDAL.")
  end
end

const OPTIONS_DEFAULT_TIFF = Dict(
  # "BIGTIFF" => "YES"
  "TILED" => "YES", # not work
  "COMPRESS" => "DEFLATE"
)

function write_tiff end

## write tiff 
# no missing value is allowed



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
