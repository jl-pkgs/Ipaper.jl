# 计算warming_level
"""
Seasonally moving thresholds

we use the fixed thresholds and add the seasonal warming signal. 

Thus, thresholds are defined as a fixed baseline (such as for the fixed threshold) plus
seasonally moving mean warming of the corresponding future climate based on the
31-year moving mean of the warmest three months.
"""
function cal_yearly_Tair(arr::AbstractArray{<:Real, 3}, dates; only_summer=false)
  if only_summer
    yms = format.(dates, "yyyy-mm")
    ys = SubString.(unique(yms), 1, 4)
    T_mon = apply(arr, 3, yms)
    T_mon = movmean(T_mon, 1; dims=3) #3个月滑动平均
    T_year = apply(T_mon, 3, ys; fun=maximum) # 最热的3个月，作为每年的升温幅度
  else
    ys = format.(dates, "yyyy")
    T_year = apply(arr, 3, ys)
  end
  T_year
end


cal_mTRS_season(arr::AbstractArray, dates) = cal_yearly_Tair(arr, dates; only_summer=true)


"""
$(TYPEDSIGNATURES)
"""
function cal_warming_level(arr::AbstractArray{<:Real, 3}, dates; 
  p1=1981, p2=2010, only_summer=false)
  
  T_year = cal_yearly_Tair(arr, dates; only_summer)
  
  # yms = format.(dates, "yyyy-mm")
  # ys = SubString.(unique(yms), 1, 4)
  # grps = unique_sort(ys)
  grps = year.(dates) |> unique_sort  
  inds_clim = @.(p1 <= grps <= p2)
  T_clim = apply(@view(T_year[:, :, inds_clim]), 3; fun=nanmean)
  
  T_year .- T_clim
end

