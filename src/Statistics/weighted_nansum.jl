weighted_sum(x::AbstractVector, w::AbstractVector) = sum(x .* w)

function weighted_nansum(x::AbstractVector{T1}, w::AbstractVector{T2}) where
{T1<:Real,T2<:Real}
  T = promote_type(T1, T2)
  ∑ = ∅ = T(0)

  @inbounds for i in eachindex(x)
    ∑ += ifelse(x[i] == x[i], x[i] * w[i], ∅)
  end
  return ∑
end

function weighted_nansum(A::AbstractArray{T,3}, w::AbstractVector) where {T<:Real}
  nlon, nlat, ntime = size(A)
  R = zeros(nlon, nlat) #.* T(NaN)

  @inbounds for i = 1:nlon, j = 1:nlat
    for k = 1:ntime
      xi = A[i, j, k]
      xi == xi && (R[i, j] += xi * w[i])
    end
  end
  return R
end


# function weighted_nanmean(x::AbstractVector{T1}, w::AbstractVector{T2}) where {T1,T2}
#   T = promote_type(T1, T2)
#   ∑ = ∅ = T(0)
#   ∑w = ∅w = T2(0)

#   @inbounds for i = eachindex(x)
#     xᵢ = x[i]
#     notnan = xᵢ == xᵢ
#     ∑ += ifelse(notnan, x[i] * w[i], ∅)
#     ∑w += ifelse(notnan, w[i], ∅w)
#   end
#   return ∑ / ∑w
# end
