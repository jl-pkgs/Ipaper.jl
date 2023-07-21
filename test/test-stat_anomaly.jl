# using Ipaper
# using Test

@testset "filter_mds" begin
  function check_mds(doy=1)
    findall(filter_mds(1:366, doy)) == sort(find_adjacent_doy(doy))
  end

  @test check_mds(1)
  @test check_mds(10)
  @test check_mds(366)
end


@testset "_cal_anomaly_3d" begin
  set_seed(1)
  ny = 10
  dates = Date(2010):Day(1):Date(2010 + ny - 1, 12, 31)
  ntime = length(dates)

  dims = (100, 100)
  set_seed(1)
  nprob = ()

  arr = rand(dims..., ntime)
  TRS = rand(dims..., 366, nprob...)
  T_wl = rand(dims..., ny)

  r1 = _cal_anomaly(arr, TRS, dates; T_wl)
  r3 = _cal_anomaly_3d(arr, TRS, dates; T_wl)

  @time r1 = _cal_anomaly(arr, TRS, dates; T_wl)
  @time r3 = _cal_anomaly_3d(arr, TRS, dates; T_wl)
  @test r1 == r3
end


@testset "cal_anomaly 3d" begin
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)
  obj_size(arr)

  ## 采用`quantile`计算
  kw = (; parallel=true, p1=1961, p2=1980, na_rm=false)
  @time anom_base = cal_anomaly_quantile(arr, dates; kw..., method="base")

  @time anom_season = cal_anomaly_quantile(arr, dates; kw..., method="season")
  @time anom_full = cal_anomaly_quantile(arr, dates; kw..., method="full")
  # @test size(anom_base) == size(anom_full)
  # @test size(anom_base) == size(anom_season)

  ## 采用`fun_clim`:`nanmean`计算
  kw = (; parallel=true, p1=1961, p2=1980, fun_clim=nanmedian)
  @time anom_base2 = cal_anomaly(arr, dates; kw..., method="base")
  @time anom_season2 = cal_anomaly(arr, dates; kw..., method="season")
  @time anom_full2 = cal_anomaly(arr, dates; kw..., method="full")

  # @test size(anom_base) == size(anom_full)
  # @test size(anom_base) == size(anom_season)
  @test anom_base == anom_base2
  @test anom_season == anom_season2
  @test anom_full ≈ anom_full2
end



# @testset "cal_anomaly 1d" begin
#   dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
#   n = length(dates)
#   set_seed(1)

#   x = rand(Float32, n)
#   obj_size(x)

#   ## 采用`quantile`计算
#   kw = (; parallel=true, p1=1961, p2=1980, na_rm=false)
#   @time anom_base = cal_anomaly_quantile(x, dates; kw..., method="base")
#   @time anom_season = cal_anomaly_quantile(x, dates; kw..., method="season")
#   @time anom_full = cal_anomaly_quantile(x, dates; kw..., method="full")
#   # @test size(anom_base) == size(anom_full)
#   # @test size(anom_base) == size(anom_season)

#   ## 采用`fun_clim`:`nanmean`计算
#   kw = (; parallel=true, p1=1961, p2=1980, fun_clim=nanmedian)
#   @time anom_base2 = cal_anomaly(x, dates; kw..., method="base")
#   @time anom_season2 = cal_anomaly(x, dates; kw..., method="season")
#   @time anom_full2 = cal_anomaly(x, dates; kw..., method="full")

#   # @test size(anom_base) == size(anom_full)
#   # @test size(anom_base) == size(anom_season)
#   @test anom_base == anom_base2
#   @test anom_season == anom_season2
#   @test anom_full ≈ anom_full2
# end
