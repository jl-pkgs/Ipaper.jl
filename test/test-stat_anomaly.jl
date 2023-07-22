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
  ny = 10
  dates = Date(2010):Day(1):Date(2010 + ny - 1, 12, 31)
  ntime = length(dates)

  dims = (100, 100)
  set_seed(1)
  nprob = ()

  set_seed(1)
  A = rand(dims..., ntime)
  TRS = rand(dims..., 366, nprob...)
  T_wl = rand(dims..., ny)

  r1 = _cal_anomaly(A, TRS, dates; T_wl)
  r3 = _cal_anomaly_3d(A, TRS, dates; T_wl)

  @time r1 = _cal_anomaly(A, TRS, dates; T_wl)
  @time r3 = _cal_anomaly_3d(A, TRS, dates; T_wl)
  @test r1 == r3
end


@testset "cal_anomaly_clim 3d" begin
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  A = rand(Float32, 4, 4, n)
  obj_size(A)

  ## 采用`quantile`计算
  kw = (; parallel=true, p1=1961, p2=1980, na_rm=false)
  @time anom_base = cal_anomaly_quantile(A, dates; kw..., method="base")

  @time anom_season = cal_anomaly_quantile(A, dates; kw..., method="season")
  @time anom_full = cal_anomaly_quantile(A, dates; kw..., method="full")

  ## 采用`fun_clim`:`nanmean`计算
  kw = (; parallel=true, p1=1961, p2=1980, fun_clim=nanmedian)
  @time anom_base2 = cal_anomaly_clim(A, dates; kw..., method="base")
  @time anom_season2 = cal_anomaly_clim(A, dates; kw..., method="season")
  @time anom_full2 = cal_anomaly_clim(A, dates; kw..., method="full")

  @test anom_base == anom_base2
  @test anom_season == anom_season2
  @test anom_full ≈ anom_full2
end



## Test for multi-dimension array  ---------------------------------------------
function test_climatology(; dims=(), T=Float32)
  A = rand(T, dims..., ntime)
  kw = (; p1=2010, p2=2015, parallel=true, use_mov=true, fun=nanmean) # 

  @time r_base = cal_climatology_base(A, dates; kw...)
  @time r_full = cal_climatology_full(A, dates; kw...)

  @test size(r_base) == (dims..., 366)
  @test size(r_full) == size(A)
end

function test_anomaly(; dims=(), T=Float32)
  A = rand(T, dims..., ntime)
  kw = (; p1=2010, p2=2015, parallel=true, use_mov=true, fun_clim=nanmean)

  r_base = cal_anomaly_clim(A, dates; kw..., method="base")
  r_seas = cal_anomaly_clim(A, dates; kw..., method="season")
  r_full = cal_anomaly_clim(A, dates; kw..., method="full")

  @test size(r_base) == size(A)
  @test size(r_seas) == size(A)
  @test size(r_full) == size(A)
end

function test_anomaly_quantile(; T=Float32, dims=(4,))
  A = rand(T, dims..., ntime)
  kw = (; parallel=true, p1=2010, p2=2015, na_rm=false, probs=[0.5, 0.9])

  anom_season = cal_anomaly_quantile(A, dates; kw..., method="season")
  anom_base = cal_anomaly_quantile(A, dates; kw..., method="base")
  anom_full = cal_anomaly_quantile(A, dates; kw..., method="full")

  @test size(anom_base) == (dims..., ntime, length(kw.probs))
  @test size(anom_base) == size(anom_full)
  @test size(anom_base) == size(anom_season)
end

ny = 10
dates = Date(2010):Day(1):Date(2010 + ny - 1, 12, 31)
ntime = length(dates)
dims = (4, 4)

@testset "climatology and anomaly in multiple dimension" begin
  l_dims = [(), (4,), (4, 4), (4, 4, 4)]
  for T in (Float32, Float64)
    for dims = l_dims
      test_climatology(; T, dims)
      test_anomaly(; T, dims)
      test_anomaly_quantile(; T, dims)
    end
  end
end
