using Test, Ipaper, Ipaper.sf, ArchGDAL

@testset "raster" begin
  b = bbox(-180.0, -60.0, 180.0, 90.0)
  A = rand(4, 4)
  r2 = rast(A, b)

  @test ndims(r2) == 2
  @test (r2 + 1).A == (1 + r2).A
  @test (r2 + r2).A == 2 * r2.A

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

  print(r3)
  @test size(r2) == (4, 4, 1)
  @test size(r3) == (4, 4, 3)

  @test (r3 + 1).A == r3.A .+ 1
  @test (r3 - 1).A == r3.A .- 1
  @test (r3 * 1).A == r3.A .* 1
  @test (r3 / 2).A == r3.A ./ 2
end



@testset "gdal_nodata" begin
  b = bbox(-180.0, -60.0, 180.0, 90.0)
  A = rand(4, 4)
  r = rast(A, b)

  write_gdal(r, "test.tif")
  @test gdal_nodata("test.tif")[1] == 0.0
  gdal_info("test.tif")

  write_gdal(r, "test2.tif"; nodata=2.0)
  @test gdal_nodata("test2.tif")[1] == 2.0
  rm.(["test.tif", "test2.tif"])
end


@testset "flipud" begin
  A = array(1:16; dims=(4, 4))
  A |> flipud |> flipud == A
  @test flipud(A)[:, 1] == [4, 3, 2, 1]

  A |> fliplr |> fliplr == A
  @test fliplr(A)[1, :] == [13, 9, 5, 1]
end
