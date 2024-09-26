using Test, Ipaper


@testset "agg_time" begin
  A = rand(100, 100, 1000)
  by = repeat(1:500, 2)
  
  R = agg_time(A)
  @test size(R) == (100, 100, 500)
  
  R = agg_time(A, by)
  @test size(R) == (100, 100, 500)
end
