using Ipaper
using Test
using BenchmarkTools


_print(x) = printstyled(x * "\n", color=:blue, bold=true, underline=true)

@testset "NanQuantile_low" begin
  year_end = 2013
  scale = 2 # local test version
  # year_end = 2010; scale = 1 # cloud tets version

  dates = make_date(2010, 1, 1):Day(1):make_date(year_end, 12, 31)
  ntime = length(dates)
  arr = rand(Float32, 140 * scale, 80 * scale, ntime)
  arr2 = copy(arr)

  # default `na_rm=true`
  @test NanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]
  @test NanQuantile_low([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]

  ## Rough time ----------------------------------------------------------------
  _print("Rough time =====================================================")
  _print("0. low version:")
  @time r0 = nanquantile(arr, dims=3) # low version

  _print("1. mapslices:")
  @time r1_0 = NanQuantile(arr; dims=3, na_rm=false)
  @time r1_1 = NanQuantile(arr; dims=3, na_rm=true)

  _print("2. for loop memory saved:")
  @time r2_0 = NanQuantile_3d(arr; dims=3, na_rm=false)
  @time r2_1 = NanQuantile_3d(arr; dims=3, na_rm=true)

  _print("3. for loop memory saved for any dimension:")
  @time r3_0 = NanQuantile_low(arr; dims=3, na_rm=false)
  @time r3_1 = NanQuantile_low(arr; dims=3, na_rm=true)

  @test r1_0 == r1_1
  @test r2_0 == r2_1
  @test r3_0 == r3_1
  @test r1_0 == r0
  @test r2_0 == r0
  @test r3_0 == r0
  @test arr2 == arr
  ## accurate time -------------------------------------------------------------
  _print("Accurate time =====================================================")
  _print("0. low version:")
  @btime r0 = nanquantile($arr, dims=3) # low version

  _print("1. mapslices:")
  @btime r1_0 = NanQuantile($arr; dims=3, na_rm=false)
  @btime r1_1 = NanQuantile($arr; dims=3, na_rm=true)

  _print("2. for loop memory saved:")
  @btime r2_0 = NanQuantile_3d($arr; dims=3, na_rm=false)
  @btime r2_1 = NanQuantile_3d($arr; dims=3, na_rm=true)

  _print("3. for loop memory saved for any dimension:")
  @btime r3_0 = NanQuantile_low($arr; dims=3, na_rm=false)
  @btime r3_1 = NanQuantile_low($arr; dims=3, na_rm=true)
end

# Accurate time =====================================================
#   5.494 s (56 allocations: 251.39 MiB)
# mapslices:
#   3.904 s (224049 allocations: 7.02 MiB)
#   1.877 s (448049 allocations: 20.69 MiB)
# for loop memory saved:
#   4.065 s (16 allocations: 881.53 KiB)
#   1.901 s (224016 allocations: 14.53 MiB)
# for loop memory saved for any dimension:
#   3.821 s (89616 allocations: 2.23 MiB)
#   1.791 s (313616 allocations: 15.90 MiB)
