export IpaperNaNExt
module IpaperNaNExt


using NaNStatistics
# using Ipaper
import Ipaper: _nanquantile!, nanmean

function _nanquantile!(q::AbstractVector, x::AbstractVector,
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1])
  for k = eachindex(probs)
    q[k] = NaNStatistics._nanquantile!(x, probs[k], (1,))[1]
  end
  q
end

function _nanquantile!(A, q::Real, dims::Int64)
  NaNStatistics._nanquantile!(A, q, dims)
end

nanmean(A; dims=:, dim=:) = NaNStatistics.nanmean(A; dims, dim)

end
