"""
$(TYPEDSIGNATURES)
"""
function cal_climatology_base!(Q::AbstractArray{T,3}, data::AbstractArray{T,3}, dates;
  use_mov=true, halfwin::Int=7,
  parallel::Bool=true, fun=nanmean, 
  type="md") where {T<:Real}
  
  if type == "doy"
    doys = dayofyear.(dates)
    doy_max = maximum(doys)
    doy_min = 1
  else
    mmdd = format_md.(dates)
    mds = mmdd |> unique |> sort
    doy_max = length(mds)
    doy_min = 1
  end

  nlon, nlat, ntime = size(data)
  # @timeit_all 
  @inbounds @par parallel for doy = doy_min:doy_max
    doys_mov = use_mov ? find_adjacent_doy(doy; doy_max=doy_max, halfwin=halfwin) : [doy]
    # ind = indexin(doys_mov, doys)
    if type == "doy"
      ind = findall(indexin(doys, doys_mov) .!= nothing)
    else
      md = mds[doys_mov]
      ind = findall(indexin(mmdd, md) .!= nothing)
    end
    
    # q = @view Q[:, :, doy, :]
    for i=1:nlon, j=1:nlat
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
  # probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  type=nothing,
  p1::Int=1961, p2::Int=1990, kw...)

  mmdd = format_md.(dates)
  doy_max = length_unique(mmdd)

  type = type === nothing ? eltype(arr) : type
  dim = size(arr)
  Q = zeros(type, dim[1:2]..., doy_max)

  # constrain date in [p1, p2]
  years = year.(dates)
  ind = findall(p1 .<= years .<= p2)
  _data = @view arr[:, :, ind]
  _dates = @view dates[ind]
  cal_climatology_base!(Q, _data, _dates; kw...)
end


"""
  cal_climatology_full
  
$(TYPEDSIGNATURES)
"""
function cal_climatology_full(arr::AbstractArray{T}, dates; 
  width=15, verbose=true, use_mov=true,
  kw...) where {T<:Real}

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
  mTRS_full = zeros(T, dim[1:3]...)
  mTRS = zeros(T, dim[1:2]..., doy_max)
  
  TRS_head = cal_climatology_base(arr, dates; p1=YEAR_MIN, p2=YEAR_MIN + width * 2, use_mov, kw...)
  TRS_tail = cal_climatology_base(arr, dates; p1=YEAR_MAX - width * 2, p2=YEAR_MAX, use_mov, kw...)

  for year = grps
    verbose && mod(year, 5) == 0 && println("running [year=$year]")

    inds_year = years .== year
    md = @view mmdd[inds_year]
    ind = findall(r_in(mds, md))

    year_beg = max(year - width, YEAR_MIN)
    year_end = min(year + width, YEAR_MAX)

    if year <= YEAR_MIN + width
      _mTRS = TRS_head
    elseif year >= YEAR_MAX - width
      _mTRS = TRS_tail
    else
      inds_data = @.(years >= year_beg && year <= year_end)
      _data = selectdim(arr, 3, inds_data)
      _dates = @view dates[inds_data]

      cal_climatology_base!(mTRS, _data, _dates; use_mov, kw...)
      _mTRS = mTRS
    end
    @views copy!(mTRS_full[:, :, inds_year], _mTRS[:, :, ind])
  end
  mTRS_full
end
