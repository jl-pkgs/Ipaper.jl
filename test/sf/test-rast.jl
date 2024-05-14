using Ipaper
using Ipaper.sf
using Test
using ArchGDAL

@testset "raster" begin
  b = bbox(-180.0, -60.0, 180.0, 90.0)
  r2 = rast(rand(4, 4), b)
  write_tiff(r2, "test.tif")
  isfile("test.tif") && rm("test.tif")

  r3 = rast(rand(4, 4, 3), b; time=1:3, bands=["a", "b", "c"])
  write_tiff(r3, "test.tif")
  isfile("test.tif") && rm("test.tif")

  print(r2)
  @test size(r2) == (4, 4, 1)
  @test size(r3) == (4, 4, 3)
  
  @test (r3 + 1).A == r3.A .+ 1
  @test (r3 - 1).A == r3.A .- 1
  @test (r3 * 1).A == r3.A .* 1
  @test (r3 / 2).A == r3.A ./ 2
end
