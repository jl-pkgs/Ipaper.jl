using Ipaper
using nctools
using JLD2
using BenchmarkTools
using Test


dates = make_date(2010, 1, 1):Day(1):make_date(2018, 12, 31)
ntime = length(dates)

# n = 100
arr = rand(Float32, 280, 160, ntime);

# @time mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);
# @profview_allocs mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);

Threads.nthreads()

@time mTRS_full_base = cal_mTRS_full(arr, dates; use_mov=true, method_q="base");
# 26.906053 seconds (992.32 k allocations: 3.217 GiB, 0.30% gc time)

@time mTRS_full_map = cal_mTRS_full(arr, dates; use_mov=true, method_q="mapslices");
# 85.192534 seconds (1.04 G allocations: 54.970 GiB, 56.29% gc time, 1.26% compilation time)

mTRS_full_map == mTRS_full_base
# T_year = cal_mTRS_seasonal(arr, dates)
