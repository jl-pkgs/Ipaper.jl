export nanmean, nansum
export weighted_mean, weighted_nanmean, weighted_sum, weighted_nansum

function nanmean(x::AbstractVector{T}) where {T<:Real}
  FT = Base.promote_op(/, T, Int)
  ∑ = ∅ = FT(0)
  n = 0
  @inbounds @simd for xᵢ in x
    notnan = xᵢ == xᵢ
    ∑ += ifelse(notnan, xᵢ, ∅)
    n += notnan
  end
  return ∑ / n
end

function nansum(x::AbstractVector{T}) where {T<:Real}
  ∑ = ∅ = T(0)
  @inbounds @simd for xᵢ in x
    ∑ += ifelse(xᵢ == xᵢ, xᵢ, ∅)
  end
  return ∑
end


# using LoopVectorization
weighted_mean(x::AbstractVector, w::AbstractVector) = sum(x .* w) / sum(w)

function weighted_nanmean(x::AbstractVector{Tx}, w::AbstractVector{Tw}) where {Tx,Tw}
  T = promote_type(Tx, Tw)
  ∑ = ∅ = T(0)
  ∑w = ∅w = Tw(0)

  @inbounds @simd for i = eachindex(x)
    xᵢ = x[i]
    notnan = xᵢ == xᵢ
    ∑ += ifelse(notnan, x[i] * w[i], ∅)
    ∑w += ifelse(notnan, w[i], ∅w)
  end
  return ∑ / ∑w
end


weighted_sum(x::AbstractVector, w::AbstractVector) = sum(x .* w)

function weighted_nansum(x::AbstractVector{Tx}, w::AbstractVector{Tw}) where
{Tx<:Real,Tw<:Real}
  T = promote_type(Tx, Tw)
  ∑ = ∅ = T(0)

  @inbounds @simd for i in eachindex(x)
    ∑ += ifelse(x[i] == x[i], x[i] * w[i], ∅)
  end
  return ∑
end

# function weighted_nansum(A::AbstractArray{T,3}, w::AbstractVector) where {T<:Real}
#   nlon, nlat, ntime = size(A)
#   R = zeros(nlon, nlat) #.* T(NaN)

#   @inbounds for i = 1:nlon, j = 1:nlat
#     for k = 1:ntime
#       xk = A[i, j, k]
#       xk == xk && (R[i, j] += xk * w[k])
#     end
#   end
#   return R
# end
