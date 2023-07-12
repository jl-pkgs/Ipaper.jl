"""
$(TYPEDSIGNATURES)
"""
function cal_climatology_base3!(Q::AbstractArray{T,3}, data::AbstractArray{T,3}, mmdd;
  use_mov=true, halfwin::Int=7,
  parallel::Bool=true, fun=nanmean,
  ignored...) where {T<:Real}

  doy_max = maximum(mmdd)

  nlon, nlat, _ = size(data)
  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)
    for i = 1:nlon, j = 1:nlat
      x = @view data[i, j, ind]
      Q[i, j, doy] = fun(x)
    end
  end
  Q
end


"""
$(TYPEDSIGNATURES)
"""
function cal_climatology_base(arr::AbstractArray{<:Real,3}, dates;
  (fun!)=cal_climatology_base3!, kw...)

  cal_mTRS_base(arr, dates; use_quantile=false, (fun!), kw...)
end


"""  
$(TYPEDSIGNATURES)
"""
function cal_climatology_full(arr::AbstractArray{T}, dates;
  (fun!)=cal_climatology_base3!, kw...) where {T<:Real}

  cal_mTRS_full(arr, dates; use_quantile=false, (fun!), kw...)
end
