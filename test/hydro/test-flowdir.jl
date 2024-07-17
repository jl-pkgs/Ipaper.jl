using Ipaper, Ipaper.sf, ArchGDAL
using Test

@testset "flowdir" begin
  indir = joinpath(@__DIR__, "../data")

  dem = read_gdal("$indir/GuanShan_dem250m.tif", 1)
  @time dir_julia = FillDEM_FlowDirection(dem) |> gis2tau

  dir_cpp = read_gdal("$indir/GuanShan_flowdir_cpp.tif", 1) |> gis2tau
  @test dir_cpp == dir_julia
end

# b = st_bbox(f)
# lon, lat = st_dims(f)
# dem_bak = deepcopy(dem)
# obj_size(dem)
