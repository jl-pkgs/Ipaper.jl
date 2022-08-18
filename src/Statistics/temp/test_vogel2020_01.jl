using Ipaper
using JLD2
using BenchmarkTools
using Test
# using nctools


dates = make_date(2010, 1, 1):Day(1):make_date(2018, 12, 31)
ntime = length(dates)

# n = 100
arr = rand(Float32, 280, 160, ntime);

# @time mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);
# @profview_allocs mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);
Threads.nthreads()

@time mTRS_full_base = cal_mTRS_full(arr, dates; use_mov=true, method_q="base", na_rm=false); "ok"


@time mTRS_full_base = cal_mTRS_full(arr, dates; use_mov=true, method_q="base", na_rm=true); "ok"
# 26.906053 seconds (992.32 k allocations: 3.217 GiB, 0.30% gc time)

@time mTRS_full_map = cal_mTRS_full(arr, dates; use_mov=true, method_q="mapslices");

# 85.192534 seconds (1.04 G allocations: 54.970 GiB, 56.29% gc time, 1.26% compilation time)

mTRS_full_map == mTRS_full_base
# T_year = cal_mTRS_seasonal(arr, dates)




using Printf
# using Base: Slice
A = rand(4, 4, 3)

begin
  dims = 3
  # _Slice_A = Base.Slice.(axes(A))
  _Slice_A = ntuple(d -> :, ndims(A))
  dim_mask = ntuple(d -> d in dims, ndims(A))

  I = CartesianIndex(1, 2, 3)

  idx = Vector{Any}(nothing, 4)
  for k in eachindex(dim_mask)
    idx[k] = ifelse(dim_mask[k], _Slice_A[k], I[k])
  end
  println("version2: $idx")

  idx = ifelse.(dim_mask, _Slice_A, Tuple(I))
  println("version1: $idx")
end
typeof(idx)

idx = [1, 2, Base.Slice(Base.OneTo(3))]
A[1, 2, :]

@view A[idx...]
