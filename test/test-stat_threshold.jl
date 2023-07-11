@testset "cal_mTRS_base" begin
  import Ipaper: cal_mTRS_base, cal_mTRS_full

  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)

  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  kw = (; probs, na_rm=true, parallel=false)

  @time r1 = cal_mTRS_base(arr, dates; kw..., method_q="mapslices")
  @time r2 = cal_mTRS_base(arr, dates; kw..., method_q="base")
  @time r3 = Threshold.cal_mTRS_base(arr, dates; kw...)

  @test r1 == r2
  @test r1 == r3
end
