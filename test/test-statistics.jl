# using Ipaper
# using Test

@testset "Quantile" begin
  n = 20
  @test size(Quantile(rand(n, n, 30); dims=3)) == (n, n, 5)
  @test size(Quantile(rand(n, n, 30); dims=2)) == (n, 5, 30)
  @test size(Quantile(rand(n, n, 30); dims=1)) == (5, 20, 30)

  # Test for missing values
  @test Quantile([1, 2, missing, 4, 5, 10]) |> size == (5,)

  ## test for missing values
  # vector
  r1 = Quantile([missing, missing], [0.1, 0.2]; dims=1)
  @test all(isnan.(r1))

  # matrix
  x = rand(4, 4) |> to_missing
  x[1:2, :] .= missing
  r2 = Quantile(x, [0.1, 0.2]; dims=2)
  @test all(isnan.(r2[1:2, 1:2]))
end
