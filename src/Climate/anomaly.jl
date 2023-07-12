## 计算anomaly的3种方法，考虑每年的升温幅度

# some CMIP6 model not use 366 calendar |> "solved"
# DateType = Union{Date,DateTime,AbstractCFDateTime,Nothing}
_gte(x::T, y::T) where {T<:Real} = x >= y
_gt(x::T, y::T) where {T<:Real} = x > y
_exceed(x::T, y::T) where {T<:Real} = x - y


"""
$(TYPEDSIGNATURES)
"""
function _cal_anomaly(
  arr::AbstractArray{T,3},
  TRS::AbstractArray{T,3},
  dates;
  T_wl::Union{AbstractArray{T,3}, Nothing}=nothing,
  parallel::Bool=false, 
  option = 2,
  # ΔTRS=nothing,
  dtype=nothing,
  fun_anom=_exceed, verbose=false
) where {T<:Real}

  dtype === nothing && (dtype = T)
  # res = BitArray(undef, size(arr))

  mmdd = format_md.(dates)
  mds = mmdd |> unique |> sort
  # doy_max = length(mds)
  
  if option == 1
    # 方案1：无法添加T_wl
    idxs = indexin(mmdd, mds)
    fun_anom.(arr, TRS[:, :, idxs])
    
  else option == 2
    res = zeros(dtype, size(arr))
    nlon, nlat, _ = size(arr)

    years = year.(dates)
    year_grps = unique(years) |> sort

    # @timeit_all 
    @par parallel for iy in 1:length(year_grps)
      year = year_grps[iy]
      
      verbose && println("year = $year")
      ind_y = findall(years .== year)
      ind_d = indexin(mmdd[ind_y], mds) # allow some doys missing

      @inbounds for i = 1:nlon, j = 1:nlat, k = eachindex(ind_y)
        x = arr[i, j, ind_y[k]]
        y = TRS[i, j, ind_d[k]] 

        if T_wl !== nothing
          y += T_wl[i, j, iy]
        end
        res[i, j, ind_y[k]] = fun_anom(x, y)
      end
    end
    res    
  end
end


## 更加傻瓜的版本
"""
$(TYPEDSIGNATURES)

# Arguments

- `method`: one of `["full", "season", "base"]`, see Vogel2020 for details

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070

"""
function cal_anomaly_quantile(
  arr::AbstractArray{T,3}, dates;
  parallel::Bool=false, 
  use_mov=true, na_rm=true,
  method = "full", 
  p1=1981, p2=2010,
  fun = _exceed, 
  probs=0.5, 
  options...
) where {T<:Real}
  
  kw = (;probs=[probs], use_mov, na_rm, parallel, options...)
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
"""
$(TYPEDSIGNATURES)
"""
function cal_anomaly(
  arr::AbstractArray{T,3},
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
    anom = _cal_anomaly(arr, mTRS, dates; option=1, fun_anom)
  elseif method == "season"
    mTRS = cal_climatology_base(arr, dates; p1, p2, kw...) |> squeeze_tail
    T_wl = cal_warming_level(arr, dates; p1, p2)
    anom = _cal_anomaly(arr, mTRS, dates; option=2, T_wl, fun_anom)
  elseif method == "full"
    TRS_full = cal_climatology_full(arr, dates; kw...) |> squeeze_tail
    anom = fun_anom.(arr, TRS_full)
  end
  anom
end



function cal_anomaly_quantile(arr::AbstractVector{<:Real}, dates; kw...)
  arr = reshape(arr, 1, 1, length(arr))
  cal_anomaly_quantile(arr, dates; kw...)[1, 1, :]
end


function cal_anomaly(arr::AbstractVector{<:Real}, dates; kw...)
  arr = reshape(arr, 1, 1, length(arr))
  cal_anomaly(arr, dates; kw...)[1, 1, :]
end
