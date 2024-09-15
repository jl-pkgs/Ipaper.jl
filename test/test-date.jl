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

@testset "date_doy" begin
  date = date_doy(2000, 49)
  @test date_doy("2000049") == date_doy(2000, 49)
  @test date_dn(Date(2000, 2, 19)) == date_dn(2000, 7) # 2000-02-18
  @test date_ym(date) == Date(2000, 2)
end
