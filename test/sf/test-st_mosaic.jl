@testset "st_mosaic" begin  
  bands = string.(1:4)
  r1 = rast(rand(4, 4, 4), bbox(-180.0, -60.0, 180.0, -30.0); bands)
  r2 = rast(rand(4, 4, 4), bbox(-180.0, -30.0, 180.0, 0.0); bands)
  
  rs = [r1, r2]
  r_big = st_mosaic(rs)
  @test st_bbox(r_big) == bbox(-180.0, -60.0, 180.0, 0.0) 
  # r_big
end
