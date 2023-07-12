export Threshold

module Threshold

export cal_mTRS_base
using Ipaper


function cal_mTRS_base!(Q::AbstractArray{T}, 
  arr::AbstractArray{T,N}, mmdd;
  dims=N,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  parallel=true, halfwin=7, use_mov=true,
  kw...) where {T<:Real, N}

  doy_max = maximum(mmdd)
  
  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)
    # idx = ntuple(i -> i == dims ? ind : Colon(), N)
    # ridx = ntuple(i -> i == dims ? doy : Colon(), N + 1)
    # x = @view(arr[idx...])
    # q = @view(Q[ridx...])
    x = selectdim(arr, dims, ind)
    q = selectdim(Q, dims, doy)
    q .= NanQuantile(x; probs, dims) # mapslices 
  end
  Q
end


function cal_mTRS_base(arr::AbstractArray{T,N}, dates;
  dims=N,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  dtype=nothing, 
  p1::Int=1961, p2::Int=1990, kw...) where {T<:Real,N}

  mmdd = factor(format_md.(dates)).refs
  doy_max = maximum(mmdd)

  nprob = length(probs)
  dtype = dtype === nothing ? eltype(arr) : dtype

  dims_r = map(d -> d in dims ? [doy_max, nprob] : size(arr, d), 1:N)
  dims_r = cat(dims_r..., dims=1)
  Q = zeros(dtype, dims_r...)

  # constrain date in [p1, p2]
  years = year.(dates)
  ind = findall(p1 .<= years .<= p2)
  _data = selectdim(arr, dims, ind)
  _mmdd = @view mmdd[ind]

  cal_mTRS_base!(Q, _data, _mmdd; dims, probs, kw...)
end



function cal_mTRS_full(arr::AbstractArray{T,N}, dates;
  dims=N,
  width=15, verbose=true, use_mov=true,
  probs=[0.90, 0.95, 0.99, 0.999, 0.9999], kw...) where {T<:Real,N}

  years = year.(dates)
  grps = unique(years)

  YEAR_MIN = minimum(grps)
  YEAR_MAX = maximum(grps)

  mmdd = factor(format_md.(dates)).refs
  mds = unique(mmdd) |> sort
  doy_max = length(mds)
  
  # 滑动平均两种不同的做法
  if !use_mov
    printstyled("running: 15d moving average first ... ")
    @time arr = movmean(arr, 7; dims, FT=Float32)
  end

  nprob = length(probs)

  dim_full = map(d -> d in dims ? [size(arr, d), nprob] : size(arr, d), 1:N) |> x -> vcat(x...)
  dim_mTRS = map(d -> d in dims ? [doy_max, nprob] : size(arr, d), 1:N) |> x -> vcat(x...)

  mTRS_full = zeros(T, dim_full...)
  mTRS      = zeros(T, dim_mTRS...)

  TRS_head = cal_mTRS_base(arr, dates; p1=YEAR_MIN, p2=YEAR_MIN + width * 2, use_mov, probs, kw...)
  TRS_tail = cal_mTRS_base(arr, dates; p1=YEAR_MAX - width * 2, p2=YEAR_MAX, use_mov, probs, kw...)

  for year = grps
    verbose && mod(year, 20) == 0 && println("running [year=$year]")

    inds_year = years .== year
    md = @view(mmdd[inds_year]) |> unique
    inds_md = findall(r_in(mds, md)) # this for mTRS

    year_beg = max(year - width, YEAR_MIN)
    year_end = min(year + width, YEAR_MAX)
    # @show year, YEAR_MIN + width, YEAR_MAX - width
    if year <= YEAR_MIN + width
      _mTRS = TRS_head
    elseif year >= YEAR_MAX - width
      _mTRS = TRS_tail
    else
      inds_data = @.(years >= year_beg && year <= year_end)
      _data = selectdim(arr, dims, inds_data)
      _mmdd = @view mmdd[inds_data]
      
      cal_mTRS_base!(mTRS, _data, _mmdd; use_mov, probs, kw...)
      _mTRS = mTRS # 366, 后面统一取ind
    end
    idx_year = ntuple(d -> d in dims ? inds_year : Colon(), N + 1)
    idx_md = ntuple(d -> d in dims ? inds_md : Colon(), N + 1)
    @views copy!(mTRS_full[idx_year...], _mTRS[idx_md...])
    # 两种方式表现差别不大
    # copy!(selectdim(mTRS_full, dims, inds_year), selectdim(_mTRS, dims, inds_md))
  end
  mTRS_full
end


end
