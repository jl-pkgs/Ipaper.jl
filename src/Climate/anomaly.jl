## 计算anomaly的3种方法，考虑每年的升温幅度
export _cal_anomaly_3d, _cal_anomaly


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

- `A`      : the 3D array of temperature data
- `dates`    : an array of dates corresponding to the temperature data
- `parallel` : whether to use parallel processing (default `true`)
- `use_mov`  : whether to use a moving window to calculate the threshold
  (default `true`)
- `method`   : the method to use for calculating the threshold, one of `["full",
  "season", "base", "pTRS"]` (default `"full"`)
- `probs`    : default `[0.5]`
- `p1`       : the start year for the reference period (default `1981`)
- `p2`       : the end year for the reference period (default `2010`)
- `fun`      : the function used to calculate the anomaly (default `_exceed`)

# Returns

An array of the same shape as `A` containing the temperature anomaly.

# References

1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
   Development of Future Heatwaves for Different Hazard Thresholds. Journal of
   Geophysical Research: Atmospheres, 125(9).
   <https://doi.org/10.1029/2019JD032070>

"""
function cal_anomaly_quantile(
  A::AbstractArray{T}, dates;
  parallel::Bool=true,
  use_mov=true, na_rm=true,
  method="full",
  p1=1981, p2=2010,
  fun=_exceed,
  probs=[0.5],
  options...
) where {T<:Real}

  kw = (; probs, use_mov, na_rm, parallel, options...)
  if method == "base"
    mTRS = cal_mTRS_base(A, dates; p1, p2, kw...) |> squeeze_tail
    anom = _cal_anomaly(A, mTRS, dates)
  elseif method == "season"
    mTRS = cal_mTRS_base(A, dates; p1, p2, kw...) |> squeeze_tail
    T_wl = cal_warming_level(A, dates; p1, p2)
    anom = _cal_anomaly(A, mTRS, dates; T_wl)
  elseif method == "full"
    TRS_full = cal_mTRS_full(A, dates; kw...) |> squeeze_tail
    anom = fun.(A, TRS_full)

  elseif method == "pTRS"
    # 最基础的方法
    years = year.(dates)
    inds = p1 .<= years .<= p2
    data = selectdim(A, ndims(A), inds)
    anom = map(prob -> begin  
      TRS = NanQuantile(data, [prob])
      fun.(A, TRS)
    end, probs)
    anom = cat(anom..., dims=ndims(A) + 1) |> squeeze_tail
  end
  anom
end


"""
$(TYPEDSIGNATURES)

Calculate the anomaly of an array relative to its climatology.

# Arguments

- `A::AbstractArray{T}`: The input array to calculate the anomaly of.
- `dates`: The dates corresponding to the input array.

- `parallel::Bool=true`: Whether to use parallel processing.
- `use_mov=true`: Whether to use a moving window to calculate the climatology.
- `method="full"`: The method to use for calculating the climatology. Can be "base", "season", or "full".
- `p1=1981`: The start year for the period to use for calculating the climatology.
- `p2=2010`: The end year for the period to use for calculating the climatology.
- `fun_clim=nanmean`: The function to use for calculating the climatology.
- `fun_anom=_exceed`: The function to use for calculating the anomaly.

# Returns
- `anom`: The anomaly of the input array relative to its climatology.

# Example
```julia
using Ipaper

# Generate some sample data
A = rand(365, 10)
dates = Date(2000, 1, 1):Day(1):Date(2000, 12, 31)

# Calculate the anomaly relative to the climatology
anom = cal_anomaly_clim(A, dates; method="base")
```
"""
function cal_anomaly_clim(
  A::AbstractArray{T},
  dates;
  parallel::Bool=true,
  use_mov=true,
  method="full",
  p1=1981, p2=2010,
  fun_clim=nanmean,
  fun_anom=_exceed
) where {T<:Real}

  kw = (; use_mov, parallel, fun=fun_clim)

  if method == "base"
    mTRS = cal_climatology_base(A, dates; p1, p2, kw...) |> squeeze_tail
    anom = _cal_anomaly(A, mTRS, dates; fun_anom)
  elseif method == "season"
    mTRS = cal_climatology_base(A, dates; p1, p2, kw...) |> squeeze_tail
    T_wl = cal_warming_level(A, dates; p1, p2)
    anom = _cal_anomaly(A, mTRS, dates; T_wl, fun_anom)
  elseif method == "full"
    TRS_full = cal_climatology_full(A, dates; kw...) |> squeeze_tail
    anom = fun_anom.(A, TRS_full)
  end
  anom
end


"""
$(TYPEDSIGNATURES)

Calculate the threshold value for a given dataset `A` and dates. The threshold value is calculated based on the specified method.

# Arguments
- `A::AbstractArray{T}`: The input data array.
- `dates`: The dates corresponding to the input data array.

- `parallel::Bool=true`: Whether to use parallel computation.
- `use_mov::Bool=true`: Whether to use moving window.
- `na_rm::Bool=true`: Whether to remove missing values.
- `method::String="full"`: Possible values are "base", "season", and "full".
- `p1::Int=1981`: The start year for the reference period.
- `p2::Int=2010`: The end year for the reference period.
- `probs::Vector{Float64}=[0.5]`: The probability levels to use for calculating the threshold value.
- `options...`: Additional options to pass to the underlying functions.

# Returns

For different methods: 

- `full`: Array with the dimension of `(dims..., ntime, nprob)`
- `base`: Array with the dimension of `(dims..., 366, nprob)`
- `season`: Array with the dimension of `(dims..., nyear)`

# Examples
```julia
dates = Date(2010, 1):Day(1):Date(2020, 12, 31);
ntime = length(dates)
data = rand(10, ntime);
cal_threshold(data, dates; p1=2010, p2=2015, method="full")
```
"""
function cal_threshold(
  A::AbstractArray{T}, dates;
  parallel::Bool=true,
  use_mov=true, na_rm=true,
  method="full",
  p1=1981, p2=2010,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  options...
) where {T<:Real}

  kw = (; probs, use_mov, na_rm, parallel, options...)
  if method == "base"
    cal_mTRS_base(A, dates; p1, p2, kw...) |> squeeze_tail
  elseif method == "season"
    # mTRS = cal_mTRS_base(A, dates; p1, p2, kw...) |> squeeze_tail
    cal_warming_level(A, dates; p1, p2)
  elseif method == "full"
    cal_mTRS_full(A, dates; kw...) |> squeeze_tail # full
  end
end
