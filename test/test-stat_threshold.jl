@testset "cal_mTRS_base" begin
  # import Ipaper: cal_mTRS_base, cal_mTRS_full
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)

  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  kw = (; probs, na_rm=true, parallel=false, (fun!)=Ipaper.cal_mTRS_base3!)

  @time r1 = cal_mTRS_base(arr, dates; kw..., method_q="mapslices")
  @time r2 = cal_mTRS_base(arr, dates; kw..., method_q="base")
  @test r1 == r2
end


@testset "Threshold_nd" begin

  kw = (; parallel=true, p1=1961, p2=1965, na_rm=true)
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) #|> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)

  @time r1 = cal_mTRS_base(arr, dates; kw..., method_q="mapslices")
  @time r3 = cal_mTRS_full(arr, dates; kw..., method_q="mapslices")

  @test_nowarn begin
    # set_seed(1)
    # 1d
    arr = rand(Float32, n)
    @time r2 = cal_mTRS_base(arr, dates; kw...)
    @time r4 = cal_mTRS_full(arr, dates; kw...)

    # 2d
    arr = rand(Float32, 4, n)
    @time r2 = cal_mTRS_base(arr, dates; kw...)
    @time r4 = cal_mTRS_full(arr, dates; kw...)

    # 3d
    arr = rand(Float32, 4, 4, n)
    @time r2 = cal_mTRS_base(arr, dates; kw...)
    @time r4 = cal_mTRS_full(arr, dates; kw...)

    # 4d
    arr = rand(Float32, 4, 4, 4, n)
    @time r2 = cal_mTRS_base(arr, dates; kw...)
    @time r4 = cal_mTRS_full(arr, dates; kw...)
  end
end


@testset "mTRS and climatology" begin
  # p1 = 1961, p2 = 1965,
  kw = (; parallel=false, na_rm=true)
  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) #|> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)

  # mTRS_base
  @time r1 = cal_climatology_base(arr, dates; fun=nanmedian, kw...)
  @time r2 = cal_mTRS_base(arr, dates; probs=[0.5], kw...)[:, :, :, 1]
  @time r3 = cal_mTRS_base(arr, dates;
    use_quantile=false, (fun!)=Ipaper.cal_climatology_base3!, fun=nanmedian, kw...)

  @test r1 == r2
  @test r2 == r3

  # mTRS_full
  @time r1 = cal_climatology_full(arr, dates; fun=nanmedian, kw...)
  @time r2 = cal_mTRS_full(arr, dates; probs=[0.5], kw...)[:, :, :, 1]
  @time r3 = cal_mTRS_full(arr, dates;
    use_quantile=false, (fun!)=Ipaper.cal_climatology_base3!, fun=nanmedian, kw...)

  @test r1 == r2
  @test r2 == r3
end
