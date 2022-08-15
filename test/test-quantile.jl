using Ipaper
using Test
# using PyPlot

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

  ## Quantile and nanquantile works
  x = rand(4, 4, 201)
  probs = [0.9, 0.99, 0.9999]

  r1 = Quantile(x, probs, dims=3)
  r2 = nanquantile(x; probs, dims=3)

  e_max = maximum(abs.(r1 - r2))
  @test e_max <= 1e-10
end


@testset "nanquantile_3d" begin
  dates = make_date(2010, 1, 1):Day(1):make_date(2011, 12, 31)
  ntime = length(dates)
  arr = rand(Float32, 280, 160, ntime)
  arr2 = copy(arr)

  # @time r1 = nanquantile(arr, dims=3);
  # 16.599892 seconds (56 allocations: 563.454 MiB, 2.18% gc time)
  @time r2 = quantile_3d(arr, dims=3)
  @time r3 = nanquantile_3d(arr, dims=3)

  @test r2 == r3
end
