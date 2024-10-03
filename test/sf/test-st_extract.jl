@testset "st_extract" begin
  points = [
    (110.7, 32.25),
    (110.72, 32.27),
    (110.71354166666667, 32.484375),
    (111.7, 32.25)
  ]

  f = guanshan_dem
  ra = rast(f)
  inds, vals = st_extract(ra, points)
  @test length(vals) == 2

  # r2 = st_resample(ra; fact=10)
  # @test size(r2) == (16, 12, 1)
end
