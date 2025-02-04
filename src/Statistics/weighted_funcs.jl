# using LoopVectorization
weighted_mean(x::AbstractVector, w::AbstractVector) = sum(x .* w) / sum(w)

function weighted_nanmean(x::AbstractVector{Tx}, w::AbstractVector{Tw}) where {Tx,Tw}
  T = promote_type(Tx, Tw)
  ∑ = ∅ = T(0)
  ∑w = ∅w = Tw(0)

  @inbounds for i = eachindex(x)
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

  @inbounds for i in eachindex(x)
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
