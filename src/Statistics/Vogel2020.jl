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


"""
Moving Threshold for Heatwaves Definition

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070
"""
function cal_mTRS_base!(res, data::AbstractArray{T}, dates;
  probs::Vector{Float64}=[0.90, 0.95, 0.99, 0.999, 0.9999],
  use_mov=true,
  halfwin::Int=7,
  parallel::Bool=true,
  type="md") where {T<:Real}

  if type == "doy"
    doys = dayofyear.(dates)
    doy_max = maximum(doys)
    doy_min = 1
  else
    mmdd = Dates.format.(dates, "mm-dd")
    mds = mmdd |> unique |> sort
    doy_max = length(mds)
    doy_min = 1
  end

  # dim = size(data)
  # nprob = length(probs)
  # res = zeros(T, dim[1:2]..., doy_max, nprob)

  @inbounds @par parallel for doy = doy_min:doy_max
    doys_mov = use_mov ? find_adjacent_doy(doy; doy_max=doy_max, halfwin=halfwin) : [doy]
    # ind = indexin(doys_mov, doys)
    if type == "doy"
      ind = findall(indexin(doys, doys_mov) .!= nothing)
    else
      md = mds[doys_mov]
      ind = findall(indexin(mmdd, md) .!= nothing)
    end
    @views res[:, :, doy, :] = Ipaper.Quantile2(data[:, :, ind], probs; dims=3)
    # @views res[:, doy] = Quantile(data[:, ind], probs)
  end
  res
end


"""
seasonally moving thresholdse

we use the fixed thresholds and add the seasonal warming signal. 

Thus, thresholds are defined as a fixed baseline (such as for the fixed threshold) plus
seasonally moving mean warming of the corresponding future climate based on the
31-year moving mean of the warmest three months.
"""
function cal_mTRS_seasonal(arr::AbstractArray, dates)
  yms = format.(dates, "yyyy-mm")
  ys = SubString.(unique(yms), 1, 4)

  T_mon = apply(arr, 3, yms)
  T_mon = movmean(T_mon, 1; dims=3) #3个月滑动平均
  T_year = apply(T_mon, 3, ys; fun=maximum) # 最热的3个月，作为每年的升温幅度
  T_year
end


"""
Moving Threshold for Heatwaves Definition

# Arguments

- `use_mov`: Boolean (default true). 
  + if `true`, 31*15 values will be used to calculate threshold for each grid; 
  + if `false`, the input `arr` is smoothed first, then only 15 values will be 
    used to calculate threshold.

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
  Development of Future Heatwaves for Different Hazard Thresholds. Journal of
  Geophysical Research: Atmospheres, 125(9).
  https://doi.org/10.1029/2019JD032070
"""
function cal_mTRS_full(arr::AbstractArray{T}, dates; width=15, verbose=true, use_mov=true, 
  probs = [0.90, 0.95, 0.99, 0.999, 0.9999], kw...) where {T <: Real}

  # 必须是完整的年份，不然会出错
  years = year.(dates)
  grps = unique(years)

  year_min = minimum(grps)
  year_max = maximum(grps)

  mmdd = Dates.format.(dates, "mm-dd")
  mds = unique(mmdd) |> sort
  doy_max = length(mds)
  # doy_min = 1
  
  if !use_mov
    printstyled("running: 15d moving average first ... ")
    @time arr = movmean(arr, 7; dims=3, FT=Float32)
  end
  
  dim = size(arr)
  nprob = length(probs)
  mTRS = zeros(T, dim[1:2]..., doy_max, nprob)

  res = map(year -> begin
      verbose && println("running [year=$year]")
      year_begin = max(year - width, year + width)
      year_end = min(year - width, year + width)

      ind = @.(years >= year_min && year <= year_max)
      _data = selectdim(arr, 3, ind)
      _dates = @view dates[ind]
      cal_mTRS_base!(mTRS, _data, _dates; use_mov=use_mov, kw...)
      
      # 使md匹配起来
      _md = @view mmdd[years.==year]
      ind = findall(indexin(mds, _md) .!= nothing)
      selectdim(mTRS, 3, ind)
    end, grps)
  cat(res..., dims=3)
end


export cal_mTRS_base, cal_mTRS_seasonal, cal_mTRS_full
