# using Ipaper
# using Test
@testset "apply" begin
  dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
  n = 100
  x = rand(n, n, 365)

  ym = format.(dates, "yyyy-mm")
  res = apply(x, 3, ym)
  @test size(res) == (n, n, 12)

  res = apply(x, 3)
  @test size(res) == (n, n)
end
