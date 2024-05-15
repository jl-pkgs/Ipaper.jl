"""
    read_gdal(file::String, options...)
    read_gdal(files::Array{String,1}, options)

# Arguments:
- `options`: other parameters to `ArchGDAL.read(dataset, options...)`.

# Return
"""
# read multiple tiff files and cbind
function read_gdal(files::Vector{<:AbstractString}, options...)
  # bands = collect(bands)
  # bands = collect(Int32, bands)
  res = map(file -> read_gdal(file, options...), files)
  res
  # vcat(res...)
end


export read_gdal
