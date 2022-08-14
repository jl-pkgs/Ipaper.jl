using Ipaper
using nctools
using JLD2
using BenchmarkTools

# 
# 70, 40

dates = make_date(2010, 1, 1):Day(1):make_date(2018, 12, 31)
ntime = length(dates)

n = 100
arr = rand(Float32, 280, 160, ntime);

@time mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);


# T_year = cal_mTRS_seasonal(arr, dates)
