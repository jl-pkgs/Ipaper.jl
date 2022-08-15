using Ipaper
using Test
# using PyPlot

@testset "missQuantile" begin
  n = 20
  @test size(missQuantile(rand(n, n, 30); dims=3)) == (n, n, 5)
  @test size(missQuantile(rand(n, n, 30); dims=2)) == (n, 5, 30)
  @test size(missQuantile(rand(n, n, 30); dims=1)) == (5, 20, 30)

  # Test for missing values
  @test missQuantile([1, 2, missing, 4, 5, 10]) |> size == (5,)

  ## test for missing values
  # vector
  r1 = missQuantile([missing, missing]; probs=[0.1, 0.2], dims=1)
  @test all_isnan(r1)

  # matrix
  x = rand(4, 4) |> to_missing
  x[1:2, :] .= missing
  r2 = missQuantile(x; probs=[0.1, 0.2], dims=2)
  @test all_isnan(r2[1:2, 1:2])

  ## missQuantile and nanquantile works
  x = rand(4, 4, 201)
  probs = [0.9, 0.99, 0.9999]

  r1 = missQuantile(x; probs, dims=3)
  r2 = nanquantile(x; probs, dims=3)
  e_max = maximum(abs.(r1 - r2))
  @test e_max <= 1e-10
end


@testset "nanQuantile" begin
  dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
  ntime = length(dates)
  arr = rand(Float32, 140, 80, ntime)
  arr2 = copy(arr)

  # default `na_rm=true`
  @test nanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]

  @time r1 = nanquantile(arr, dims=3) # low version
  # 16.599892 seconds (56 allocations: 563.454 MiB, 2.18% gc time)
  @time r2 = nanQuantile(arr; dims=3, na_rm=false)
  @time r3 = nanQuantile(arr; dims=3, na_rm=true)

  @test r1 == r2
  @test r2 == r3
  @test arr2 == arr
end
