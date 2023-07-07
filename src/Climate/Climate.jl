using Dates
using Printf: @sprintf

# format_md(date) = @sprintf("%02d-%02d", month(date), day(date))
format_md(date) = month(date)*100 + day(date)


include("threshold.jl")
include("climatology.jl")
include("anomaly.jl")
include("warming_level.jl")

# export cal_mTRS_base, cal_mTRS_season, cal_mTRS_full
export format_md
export cal_climatology_base, cal_climatology_full, cal_climatology_full, 
  _cal_anomaly, cal_anomaly_quantile, cal_anomaly,
  cal_warming_level, cal_yearly_Tair
