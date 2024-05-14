function read_gdal(file::AbstractString, options...)
  ArchGDAL.read(file) do dataset
    ArchGDAL.read(dataset, options...)
  end
end
