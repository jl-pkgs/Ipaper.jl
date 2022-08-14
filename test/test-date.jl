# using Dates
# using Ipaper

@testset "date" begin
  t = make_date(2010, 12, 1):Day(1):make_date(2010, 12, 31)
  x = collect(t)

  dates_miss(x) == DateTime[]
  dates_nmiss(x) == 0

  @test dates_miss(t) == DateTime[]
  @test dates_nmiss(t) == 0
end
