@testset "Quantile" begin
  n = 20
  @test size(Quantile(rand(n, n, 30); dims = 3)) == (n, n, 5)
  @test size(Quantile(rand(n, n, 30); dims = 2)) == (n, 5, 30)
  @test size(Quantile(rand(n, n, 30); dims = 1)) == (5, 20, 30)

  # Test for missing values
  @test Quantile([1, 2, missing, 4, 5, 10]) |> size == (5, )
end
