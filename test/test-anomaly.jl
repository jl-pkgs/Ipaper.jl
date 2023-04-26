# using Ipaper
# using Test
# 傻瓜模式

@testset "cal_anomaly" begin
  
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 35, 20, n)
  obj_size(arr)

  ## 采用`quantile`计算
  kw = (; parallel=true, p1=1961, p2=1980)
  @time anom_full = cal_anomaly_quantile(arr, dates; kw..., method="full")
  @time anom_base = cal_anomaly_quantile(arr, dates; kw..., method="base")
  @time anom_season = cal_anomaly_quantile(arr, dates; kw..., method="season")

  @test size(anom_base) == size(anom_full)
  @test size(anom_base) == size(anom_season)


  ## 采用`fun_clim`:`nanmean`计算
  kw = (; parallel=true, p1=1961, p2=1980, fun_clim=nanmedian)
  @time anom_full2 = cal_anomaly(arr, dates; kw..., method="full")
  @time anom_base2 = cal_anomaly(arr, dates; kw..., method="base")
  @time anom_season2 = cal_anomaly(arr, dates; kw..., method="season")

  @test size(anom_base) == size(anom_full)
  @test size(anom_base) == size(anom_season)

  @test anom_base == anom_base2
  @test anom_season == anom_season2
  @test anom_full ≈ anom_full2
end

## debug
# diff = abs.(anom_full - anom_full2)
# maximum(diff)
# diff_year = apply(diff, by = year.(dates))
# vals = map(i -> maximum(diff_year[:, :, i]), 1:40)
# inds_bad = findall(vals .> 0)
# diff_year[:, :, inds_bad[1]]
