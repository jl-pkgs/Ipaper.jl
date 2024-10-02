using Dates, Ipaper, Test

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

@testset "interval" begin
  @test interval_intersect((1, 3), (4, 5)) == 0
  @test interval_intersect((1, 3), (3, 5)) == 0
  @test interval_intersect((1, 3), (2, 4)) == 1

  @test interval_intersect(
    (Date(2001, 1, 1), Date(2001, 1, 4)),
    (Date(2001, 1, 3), Date(2001, 1, 5))
  ) == Day(1)
end

@testset "weight_d8mon" begin
  dates = Date(2010):Day(8):Date(2010, 12, 31) |> collect
  d = weight_d8mon(dates, Date(2010, 2)) |> DataFrame

  @test d.days == [1, 8, 8, 8, 3]
  @test d.w == [1, 8, 8, 8, 3] / 8
end
