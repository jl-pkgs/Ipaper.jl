@testset "cal_mTRS_base" begin
  import Ipaper: cal_mTRS_base, cal_mTRS_full

  dates = make_date(1961, 1, 1):Day(1):make_date(2000, 12, 31) |> collect
  n = length(dates)
  set_seed(1)

  arr = rand(Float32, 4, 4, n)

  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  na_rm = true

  @time r1 = cal_mTRS_base(arr, dates; probs, na_rm, method_q="mapslices")
  @time r2 = cal_mTRS_base(arr, dates; probs, na_rm, method_q="base")
  @test r1 == r2
end
