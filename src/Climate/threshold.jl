export cal_mTRS_base, cal_mTRS_full


"""
$(TYPEDSIGNATURES)
"""
function cal_mTRS_base3!(Q::AbstractArray, data::AbstractArray{T,3}, mmdd;
  dims=3,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  parallel::Bool=true, halfwin::Int=7, use_mov=true,
  method_q="base", na_rm=false,
  ignore...) where {T<:Real}

  doy_max = maximum(mmdd)
  
  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)

    q = @view Q[:, :, doy, :]
    x = @view data[:, :, ind] # 这一步耗费内存
    if method_q == "base"
      NanQuantile_3d!(q, x; probs, dims, na_rm)
      # NanQuantile_low!(q, x; probs, dims=3, na_rm)
    elseif method_q == "mapslices"
      q .= NanQuantile(x; probs, dims, na_rm) # mapslices is suppressed for 3d `NanQuantile`
    end
  end
  Q
end


"""
$(TYPEDSIGNATURES)
"""
function cal_mTRS_base!(Q::AbstractArray{T},
  arr::AbstractArray{T,N}, mmdd;
  dims=N,
  fun=NanQuantile,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  parallel=true, halfwin=7, use_mov=true,
  ignore...) where {T<:Real,N}

  doy_max = maximum(mmdd)

  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)
    # idx = ntuple(i -> i == dims ? ind : Colon(), N)
    # ridx = ntuple(i -> i == dims ? doy : Colon(), N + 1)
    # x = @view(arr[idx...])
    # q = @view(Q[ridx...])
    x = selectdim(arr, dims, ind)
    q = selectdim(Q, dims, doy)
    q .= fun(x; probs, dims) # NanQuantile, mapslices 
  end
  Q
end



"""
    $(TYPEDSIGNATURES)

Moving Threshold for Heatwaves Definition

# Arguments
- `arr` : `time` should be in the last dimension.

- `type`: The matching type of the moving `doys`, "md" (default) or "doy".

# Return
- `TRS`: in the dimension of `[nlat, nlon, ndoy, nprob]`

# References
1. Vogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020).
   Development of Future Heatwaves for Different Hazard Thresholds. Journal of
   Geophysical Research: Atmospheres, 125(9).
   <https://doi.org/10.1029/2019JD032070>
"""
function cal_mTRS_base(arr::AbstractArray{T,N}, dates;
  dims=N,
  use_quantile=true, (fun!)=cal_mTRS_base!,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  dtype=nothing,
  p1::Int=1961, p2::Int=1990, kw...) where {T<:Real,N}

  mmdd = factor(format_md.(dates)).refs
  doy_max = maximum(mmdd)

  nprob = length(probs)
  dtype = dtype === nothing ? eltype(arr) : dtype

  if use_quantile
    dims_r = map(d -> d in dims ? [doy_max, nprob] : size(arr, d), 1:N) |> x -> vcat(x...)
  else
    dims_r = map(d -> d in dims ? doy_max : size(arr, d), 1:N) |> x -> vcat(x...)
  end
  Q = zeros(dtype, dims_r...)

  # constrain date in [p1, p2]
  inds = p1 .<= year.(dates) .<= p2
  _data = selectdim(arr, dims, inds)
  _mmdd = @view mmdd[inds]

  fun!(Q, _data, _mmdd; dims, probs, kw...)
end

cal_mTRS = cal_mTRS_base



"""
$(TYPEDSIGNATURES)

Moving Threshold for Heatwaves Definition

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
   <https://doi.org/10.1029/2019JD032070>
"""
function cal_mTRS_full(arr::AbstractArray{T,N}, dates;
  dims=N,
  width=15, verbose=true,
  use_quantile=true, (fun!)=cal_mTRS_base!,
  use_mov=true,
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

  if use_quantile
    nprob = length(probs)
    dim_full = map(d -> d in dims ? [size(arr, d), nprob] : size(arr, d), 1:N) |> x -> vcat(x...)
    dim_mTRS = map(d -> d in dims ? [doy_max, nprob] : size(arr, d), 1:N) |> x -> vcat(x...)
  else
    dim_full = size(arr)
    dim_mTRS = map(d -> d in dims ? doy_max : size(arr, d), 1:N) |> x -> vcat(x...)
  end

  mTRS_full = zeros(T, dim_full...)
  mTRS = zeros(T, dim_mTRS...)

  TRS_head = zeros(T, dim_mTRS...)
  TRS_tail = zeros(T, dim_mTRS...)
  inds_head = findall(YEAR_MIN .<= years .<= (YEAR_MIN + width * 2))
  inds_tail = findall((YEAR_MAX - width * 2) .<= years .<= YEAR_MAX)
  fun!(TRS_head, selectdim(arr, dims, inds_head), @view(mmdd[inds_head]); use_mov, probs, kw...)
  fun!(TRS_tail, selectdim(arr, dims, inds_tail), @view(mmdd[inds_tail]); use_mov, probs, kw...)
  
  for year = grps
    verbose && mod(year, 20) == 0 && println("running [year=$year]")

    inds_year = years .== year
    md = @view(mmdd[inds_year]) |> unique
    inds_md = findall(r_in(mds, md)) # this for mTRS

    year_beg = max(year - width, YEAR_MIN)
    year_end = min(year + width, YEAR_MAX)

    if year <= YEAR_MIN + width
      _mTRS = TRS_head
    elseif year >= YEAR_MAX - width
      _mTRS = TRS_tail
    else
      inds_data = year_beg .<= years .<= year_end
      _data = selectdim(arr, dims, inds_data)
      _mmdd = @view mmdd[inds_data]

      fun!(mTRS, _data, _mmdd; use_mov, probs, kw...)
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


cal_pTRS(A; kw...) = NanQuantile(A; kw...)

function cal_pTRS(A, dates; p1=1981, p2=2010, probs=[0.90, 0.95, 0.99, 0.999, 0.9999], kw...)
  inds = p1 .<= year.(dates) .<= p2
  data = selectdim(A, ndims(A), inds)
  NanQuantile(data; probs, kw...)
end
