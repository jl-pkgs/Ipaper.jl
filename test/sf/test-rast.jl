using Ipaper
using Ipaper.sf
using Test
using ArchGDAL

@testset "raster" begin
  b = bbox(-180.0, -60.0, 180.0, 90.0)
  A = rand(4, 4)
  r2 = rast(A, b)
  
  f = "test.tif"
  write_gdal(r2, f)
  @test read_gdal(f)[:, :, 1] == A
  @test st_bbox(f) == b
  isfile(f) && rm(f)

  A = rand(4, 4, 3)
  r3 = rast(A, b; time=1:3, bands=["a", "b", "c"])
  st_write(r3, f)
  @test st_read(f) == A
  @test st_bbox(f) == b
  isfile(f) && rm(f)

  print(r2)
  @test size(r2) == (4, 4, 1)
  @test size(r3) == (4, 4, 3)
  
  @test (r3 + 1).A == r3.A .+ 1
  @test (r3 - 1).A == r3.A .- 1
  @test (r3 * 1).A == r3.A .* 1
  @test (r3 / 2).A == r3.A ./ 2
end
