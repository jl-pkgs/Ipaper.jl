export Threshold

module Threshold

export cal_mTRS_base
using Ipaper


function cal_mTRS_base(arr::AbstractArray{T,N}, dates;
  dims=N,
  probs::Vector=[0.90, 0.95, 0.99, 0.999, 0.9999],
  dtype=nothing,
  parallel=true, halfwin=7, use_mov=true,
  p1::Int=1961, p2::Int=1990, kw...) where {T<:Real,N}

  mmdd = format_md.(dates)
  doy_max = length_unique(mmdd)

  nprob = length(probs)
  dtype = dtype === nothing ? eltype(arr) : dtype

  dims_r = map(d -> d in dims ? [doy_max, nprob] : size(arr, d), 1:N)
  dims_r = cat(dims_r..., dims=1)
  Q = zeros(dtype, dims_r...)

  # constrain date in [p1, p2]
  years = year.(dates)
  ind = findall(p1 .<= years .<= p2)
  _data = @view arr[:, :, ind]
  _dates = @view dates[ind]

  mmdd = factor(format_md.(_dates)).refs
  mds = mmdd |> unique_sort
  doy_max = length(mds)

  @inbounds @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)

    idx = ntuple(i -> i == dims ? ind : Colon(), N)
    ridx = ntuple(i -> i == dims ? doy : Colon(), N + 1)

    x = @view(_data[idx...])
    q = @view(Q[ridx...])

    q .= NanQuantile(x; probs, dims) # mapslices 
  end
  Q
end


end
