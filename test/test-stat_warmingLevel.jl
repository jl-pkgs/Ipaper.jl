import Ipaper: cal_mTRS_season, cal_climatology_season


@testset "warmLevel" begin
  dates = make_date(1961):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)
  obj_size(arr)  

  @test_nowarn T1 = cal_warming_level(arr, dates; only_summer=true, p1=1961, p2=2000)
  @test_nowarn T2 = cal_warming_level(arr, dates; only_summer=false, p1=1961, p2=2000)

  # r1 =cal_mTRS_season(arr, dates)
  # r2 = cal_climatology_season(arr, dates)
end
