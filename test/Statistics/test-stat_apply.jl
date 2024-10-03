# using Ipaper
using Test

@testset "apply" begin
  dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
  n = 10

  ## 3-d
  x = rand(n, n, 365)
  ym = format.(dates, "yyyy-mm")
  
  res = apply(x, 3; by=ym)
  @test size(res) == (n, n, 12)

  res = apply(x, 3)
  @test size(res) == (n, n)

  ## 4-d
  x = rand(n, n, 365, 20)
  ym = format.(dates, "yyyy-mm")

  res = apply(x, 3; by=ym)
  @test size(res) == (n, n, 20, 12); # by在最后一维

  res = apply(x, 3)
  @test size(res) == (n, n, 20)

  res = apply(x, 3; by=ym, fun=NanQuantile, probs=[0.1, 0.9])
  @test size(res) == (n, n, 2, 20, 12)

  res = apply(x, 3; fun=NanQuantile, probs=[0.1, 0.9])
  @test size(res) == (n, n, 2, 20)
end
