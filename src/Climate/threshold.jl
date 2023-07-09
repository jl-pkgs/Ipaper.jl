# function find_adjacent_doy2(doy::Int; doy_max::Int=366, halfwin::Int=7)
#   ind = (-halfwin:halfwin) .+ doy

#   if ind[end] > doy_max
#     [doy-halfwin:doy_max, 1:ind[end]-doy_max]
#   elseif ind[1] < 1
#     [1:ind[end], ind[1]+doy_max:doy_max]
#   else
#     [ind]
#   end
# end

function find_adjacent_doy(doy::Int; doy_max::Int=366, halfwin::Int=7)
  ind = collect(-halfwin:halfwin) .+ doy
  for i = eachindex(ind)
    if ind[i] > doy_max
      ind[i] = ind[i] - doy_max
    end
    if ind[i] <= 0
      ind[i] = ind[i] + doy_max
    end
  end
  ind
end

function filter_mds(mmdd::AbstractVector, doy::Int; doy_max::Int=366, halfwin::Int=7, use_mov=true)
  !use_mov && (return mmdd .== doy)

  ind = (-halfwin:halfwin) .+ doy
  if ind[end] > doy_max
    # ind1, ind2 = doy-halfwin:doy_max, 1:ind[end]-doy_max
    @.(doy - halfwin <= mmdd <= doy_max || 1 <= mmdd <= ind[end] - doy_max)
  elseif ind[1] < 1
    # ind1, ind2 = 1:ind[end], ind[1]+doy_max:doy_max
    @.(1 <= mmdd <= ind[end] || ind[1] + doy_max <= mmdd <= doy_max)
  else
    @.(ind[1] <= mmdd <= ind[end])
  end
end


export find_adjacent_doy, filter_mds


"""
Moving Threshold for Heatwaves Definition

$(TYPEDSIGNATURES)

# Arguments

- `method_q`: method to calculate quantile, one of `base`, `mapslices`.
  `base` is about 3 times faster and reduce used memory in 20 times. 

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070
"""
function cal_mTRS_base!(Q::AbstractArray{T}, data::AbstractArray{T}, dates;
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  use_mov=true,
  halfwin::Int=7,
  parallel::Bool=true,
  method_q="base", na_rm=false,
  type="md", ignore...) where {T<:Real}

  # if type == "doy"
  #   doys = dayofyear.(dates)
  #   doy_max = maximum(doys)
  # else
  mmdd = factor(format_md.(dates)).refs
  mds = mmdd |> unique_sort
  doy_max = length(mds)

  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)

    q = @view Q[:, :, doy, :]
    x = @view data[:, :, ind] # 这一步耗费内存
    # q = Q[:, :, doy, :]
    # x = data[:, :, ind]
    if method_q == "base"
      NanQuantile_3d!(q, x; probs, dims=3, na_rm)
      # NanQuantile_low!(q, x; probs, dims=3, na_rm)
    elseif method_q == "mapslices"
      q .= NanQuantile(x; probs, dims=3, na_rm) # mapslices is suppressed for 3d `NanQuantile`
    end
  end
  Q
end


"""
  $(TYPEDSIGNATURES)

# Arguments
- `type`: The matching type of the moving `doys`, "md" (default) or "doy".

# Return
- `TRS`: in the dimension of `[nlat, nlon, ndoy, nprob]`
"""
function cal_mTRS_base(arr::AbstractArray{<:Real,3}, dates;
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  dtype=nothing,
  p1::Int=1961, p2::Int=1990, kw...)

  mmdd = format_md.(dates)
  doy_max = length_unique(mmdd)

  dim = size(arr)
  nprob = length(probs)
  dtype = dtype === nothing ? eltype(arr) : dtype
  Q = zeros(dtype, dim[1:2]..., doy_max, nprob)

  # constrain date in [p1, p2]
  years = year.(dates)
  ind = findall(p1 .<= years .<= p2)
  _data = @view arr[:, :, ind]
  _dates = @view dates[ind]

  cal_mTRS_base!(Q, _data, _dates; probs, kw...)
end

cal_mTRS = cal_mTRS_base;


"""
Moving Threshold for Heatwaves Definition

$(TYPEDSIGNATURES)

# Arguments

- `use_mov`: Boolean (default true). 
  + if `true`, 31*15 values will be used to calculate threshold for each grid; 
  + if `false`, the input `arr` is smoothed first, then only 15 values will be 
    used to calculate threshold.

!!! 必须是完整的年份，不然会出错

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070
"""
function cal_mTRS_full(arr::AbstractArray{T}, dates; width=15, verbose=true, use_mov=true,
  probs=[0.90, 0.95, 0.99, 0.999, 0.9999], kw...) where {T<:Real}

  years = year.(dates)
  grps = unique(years)

  YEAR_MIN = minimum(grps)
  YEAR_MAX = maximum(grps)

  mmdd = format_md.(dates)
  mds = unique(mmdd) |> sort
  doy_max = length(mds)

  # 滑动平均两种不同的做法
  if !use_mov
    printstyled("running: 15d moving average first ... ")
    @time arr = movmean(arr, 7; dims=3, FT=Float32)
  end

  dim = size(arr)
  nprob = length(probs)

  mTRS_full = zeros(T, dim[1:3]..., nprob)
  mTRS = zeros(T, dim[1:2]..., doy_max, nprob)

  TRS_head = cal_mTRS_base(arr, dates; p1=YEAR_MIN, p2=YEAR_MIN + width * 2, use_mov, probs, kw...)
  TRS_tail = cal_mTRS_base(arr, dates; p1=YEAR_MAX - width * 2, p2=YEAR_MAX, use_mov, probs, kw...)

  # reset_timer!(to)
  for year = grps
    verbose && mod(year, 20) == 0 && println("running [year=$year]")

    inds_year = years .== year
    md = @view(mmdd[inds_year]) |> unique
    inds = findall(r_in(mds, md)) # this for mTRS

    year_beg = max(year - width, YEAR_MIN)
    year_end = min(year + width, YEAR_MAX)
    # @show year, YEAR_MIN + width, YEAR_MAX - width
    if year <= YEAR_MIN + width
      _mTRS = TRS_head
    elseif year >= YEAR_MAX - width
      _mTRS = TRS_tail
    else
      # @timeit_all 
      begin
        inds_data = @.(years >= year_beg && year <= year_end)
        _data = selectdim(arr, 3, inds_data)
        _dates = @view dates[inds_data]

        # mTRS = cal_mTRS_base(_data, _dates; use_mov, probs, kw...)
        cal_mTRS_base!(mTRS, _data, _dates; use_mov, probs, kw...)
        _mTRS = mTRS # 366, 后面统一取ind
      end
    end

    @views copy!(mTRS_full[:, :, inds_year, :], _mTRS[:, :, inds, :])
  end
  mTRS_full
end
