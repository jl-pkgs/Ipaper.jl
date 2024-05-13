using Ipaper
using Ipaper.sf
using Test

@testset "raster" begin
  b = bbox(-180.0, -60.0, 180.0, 90.0)
  r2 = rast(rand(4, 4), b)
  r3 = rast(rand(4, 4, 3), b; time=1:3) # 维度如何设置

  print(r2)
  @test size(r2) == (4, 4)
  @test size(r3) == (4, 4, 3)
  
  @test (r3 + 1).A == r3.A .+ 1
  @test (r3 - 1).A == r3.A .- 1
  @test (r3 * 1).A == r3.A .* 1
  @test (r3 / 2).A == r3.A ./ 2
end
