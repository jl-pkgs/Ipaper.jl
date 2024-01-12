using Test
using Ipaper

@testset "mpi" begin
  @test_nowarn get_clusters()
  @test_nowarn isCurrentWorker()
end

@testset "par_map" begin
  @test par_map(x -> x, 1:10) == collect(1:10)
end

@testset "par_mapslices" begin
  A = rand(10, 10, 30, 4)
  r = mapslices(mean, A; dims = 3) #|> squeeze
  r1 = par_mapslices(mean, A; dims = 3)
  @test r ≈ r1
end
