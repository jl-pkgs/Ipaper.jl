"""
Calculate yearly air temperature.

# Description
we use the fixed thresholds and add the seasonal warming signal. Thus,
thresholds are defined as a fixed baseline (such as for the fixed threshold)
plus seasonally moving mean warming of the corresponding future climate based on
the 31-year moving mean of the warmest three months.

# Details
This function calculates the yearly air temperature based on the input
temperature data and dates. If `only_summer` is true, it only calculates the
temperature for summer months. The function applies the calculation along the
specified dimensions.

# Arguments
- `A::AbstractArray{T,N}`: input array of temperature data.
- `dates`: array of dates corresponding to the temperature data.
- `dims=N`: dimensions to apply the function along.
- `only_summer=false`: if true, only calculate temperature for summer months.

# Returns
- `T_year`: array of yearly temperature data.
"""
function cal_yearly_Tair(A::AbstractArray{T,N}, dates;
  dims=N, only_summer=false) where {T<:Real,N}

  if only_summer
    years = year.(dates)
    months = month.(dates)
    yms = years .* 100 .+ months
    # yms = format.(dates, "yyyy-mm")
    T_mon = apply(A, dims; by=yms)
    T_mon = movmean(T_mon, 1; dims) #3个月滑动平均
    
    ys = fld.(unique(yms), 100) # convert `year * 100 + month` to `year`
    T_year = apply(T_mon, dims; by=ys, fun=maximum) # 最热的3个月，作为每年的升温幅度
  else
    ys = year.(dates)
    T_year = apply(A, dims; by=ys)
  end
  T_year
end

cal_climatology_season(A::AbstractArray, dates) = cal_yearly_Tair(A, dates; only_summer=false)

cal_mTRS_season(A::AbstractArray, dates) = cal_yearly_Tair(A, dates; only_summer=true)


"""
$(TYPEDSIGNATURES)
"""
function cal_warming_level(A::AbstractArray{T,N}, dates;
  p1=1981, p2=2010, dims=N, only_summer=false) where {T<:Real,N}

  T_year = cal_yearly_Tair(A, dates; dims, only_summer)

  # yms = format.(dates, "yyyy-mm")
  # ys = SubString.(unique(yms), 1, 4)
  grps = year.(dates) |> unique_sort
  inds_clim = @.(p1 <= grps <= p2)

  T_year_clim = selectdim(T_year, dims, inds_clim)
  T_clim = apply(T_year_clim, dims; fun=nanmean)

  T_year .- T_clim
end
