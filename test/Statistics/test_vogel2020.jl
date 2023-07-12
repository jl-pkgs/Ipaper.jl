@time using Ipaper

using nctools
using JLD2

function _ncwrite(mTRS_full, outfile="OBS_mTRS_full_V2.nc")
  _dims = nc_dims(f)
  probs = [0.9, 0.95, 0.99, 0.999, 0.9999]
  dim_prob = NcDim("prob", probs)
  dims = [_dims; dim_prob]

  @time nc_write(outfile, "mTRS", mTRS_full, dims; compress=1, overwrite=true)
  # jldsave("OBS_mTRS_full_V1.jld2"; mTRS_full, lon, lat, dates, compress=true)
end

f = "/share/Data/CN0.5.1_ChinaDaily_025x025/HI-Tmax_CN05.1_1961_2021_daily_025x025.nc"
lon = nc_read(f, "lon")
lat = nc_read(f, "lat")

dates = nc_date(f)
@time arr = nc_read(f);
r_range(dates)
# size(arr)
# length(dates)
# dates[[1, end]]

# T_year = cal_mTRS_seasonal(arr, dates)

# `mTRS_full`最耗时
Threads.nthreads()

if false
  @time mTRS_full = cal_mTRS_full(arr, dates; use_mov=true);
  _ncwrite(mTRS_full, "OBS_mTRS_full_V2.nc")
end
# 1675.866281 seconds (8.29 G allocations: 3.986 TiB, 24.24% gc time, 0.45% compilation time)
# 0.465 hours, 16 threads
  
# @profview_allocs mTRS_full = cal_mTRS_full(arr, dates; probs=[0.9]);
@time mTRS_full_simple = cal_mTRS_full(arr, dates; use_mov=false);
_ncwrite(mTRS_full_simple, "OBS_mTRS_full_simple_V2.nc")
