## 计算anomaly的3种方法，考虑每年的升温幅度
export _cal_anomaly_3d, _cal_anomaly

# some CMIP6 model not use 366 calendar |> "solved"
# DateType = Union{Date,DateTime,AbstractCFDateTime,Nothing}
_gte(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x >= trs + wl
_gt(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x > trs + wl
_exceed(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x - trs + wl


"""
$(TYPEDSIGNATURES)
"""
function _cal_anomaly_3d(
  A::AbstractArray{T,3},
  TRS::AbstractArray{T,3},
  dates;
  T_wl::Union{AbstractArray{T,3},Nothing}=nothing,
  fun_anom=_exceed, ignored...
) where {T<:Real}

  mmdd = format_md.(dates)
  mds = mmdd |> unique |> sort

  years = year.(dates)
  year_grps = years |> unique_sort

  ind_d = indexin(mmdd, mds)
  ind_y = indexin(years, year_grps)

  _wl = T_wl === nothing ? T(0) : T_wl[:, :, ind_y]
  fun_anom.(A, TRS[:, :, ind_d], _wl)
end


function _cal_anomaly(
  A::AbstractArray{T,Na},
  TRS::AbstractArray{T,Nt},
  dates;
  T_wl::Union{AbstractArray{T,Na},Nothing}=nothing,
  fun_anom=_exceed,
  deep=true,
  ignored...
) where {T<:Real,Na,Nt}

  mmdd = format_md.(dates)
  mds = mmdd |> unique_sort

  years = year.(dates)
  year_grps = years |> unique_sort

  ind_d = indexin(mmdd, mds)
  ind_y = indexin(years, year_grps)

  _wl = T_wl === nothing ? T(0) : selectdim_deep(T_wl, Na, ind_y; deep)
  fun_anom.(A, selectdim_deep(TRS, Na, ind_d; deep), _wl)
  # broadcast(fun_anom, A, deepcopy(selectdim(TRS, Na, ind_d)), _wl)
end


"""
$(TYPEDSIGNATURES)

Calculate the anomaly of a 3D array of temperature data.

# Arguments

- `arr`      : the 3D array of temperature data
- `dates`    : an array of dates corresponding to the temperature data
- `parallel` : whether to use parallel processing (default `false`)
- `use_mov`  : whether to use a moving window to calculate the threshold (default `true`)
- `method`   : the method to use for calculating the threshold, one of `["full", "season", "base"]` (default `"full"`)
- `probs`    : default `[0.5]`
- `p1`       : the start year for the reference period (default `1981`)
- `p2`       : the end year for the reference period (default `2010`)
- `fun_clim` : the function to use for calculating the climate state, one of `nanmean` or `nanmedian` (default `nanmean`)

# Returns

An array of the same shape as `arr` containing the temperature anomaly.

# References

1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070

"""
function cal_anomaly_quantile(
  arr::AbstractArray{T}, dates;
  parallel::Bool=false,
  use_mov=true, na_rm=true,
  method="full",
  p1=1981, p2=2010,
  fun=_exceed,
  probs=[0.5],
  options...
) where {T<:Real}

  kw = (; probs, use_mov, na_rm, parallel, options...)
  # TODO: 多个阈值，需要再嵌套for循环了
  if method == "base"
    mTRS = cal_mTRS_base(arr, dates; p1, p2, kw...) |> squeeze_tail
    anom = _cal_anomaly(arr, mTRS, dates; option=1)
  elseif method == "season"
    mTRS = cal_mTRS_base(arr, dates; p1, p2, kw...) |> squeeze_tail
    T_wl = cal_warming_level(arr, dates; p1, p2)
    anom = _cal_anomaly(arr, mTRS, dates; option=2, T_wl)
  elseif method == "full"
    TRS_full = cal_mTRS_full(arr, dates; kw...) |> squeeze_tail
    anom = fun.(arr, TRS_full)
  end
  anom
end


# 气候态用的是median的方法，如果想计算均值则需要另一套独立的方法

function cal_anomaly(
  arr::AbstractArray{T},
  dates;
  parallel::Bool=false,
  use_mov=true,
  method="full",
  p1=1981, p2=2010,
  fun_clim=nanmean,
  fun_anom=_exceed
) where {T<:Real}

  kw = (; use_mov, parallel, fun=fun_clim)

  if method == "base"
    mTRS = cal_climatology_base(arr, dates; p1, p2, kw...) |> squeeze_tail
    anom = _cal_anomaly(arr, mTRS, dates; fun_anom)
  elseif method == "season"
    mTRS = cal_climatology_base(arr, dates; p1, p2, kw...) |> squeeze_tail
    T_wl = cal_warming_level(arr, dates; p1, p2)
    anom = _cal_anomaly(arr, mTRS, dates; T_wl, fun_anom)
  elseif method == "full"
    TRS_full = cal_climatology_full(arr, dates; kw...) |> squeeze_tail
    anom = fun_anom.(arr, TRS_full)
  end
  anom
end


# function cal_anomaly_quantile(arr::AbstractVector{<:Real}, dates; kw...)
#   arr = reshape(arr, 1, 1, length(arr))
#   cal_anomaly_quantile(arr, dates; kw...)[1, 1, :]
# end


# function cal_anomaly(arr::AbstractVector{<:Real}, dates; kw...)
#   arr = reshape(arr, 1, 1, length(arr))
#   cal_anomaly(arr, dates; kw...)[1, 1, :]
# end
