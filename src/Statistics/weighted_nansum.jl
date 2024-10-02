weighted_sum(x::AbstractVector, w::AbstractVector) = sum(x .* w)

function weighted_nansum(x::AbstractVector{T}, w::AbstractVector) where {T<:Real}
  ∑ = T(0)
  @inbounds for i in eachindex(x)
    ∑ += ifelse(x[i] == x[i], x[i] * w[i], T(0))
  end
  return ∑
end

function weighted_nansum(A::AbstractArray{T,3}, w::AbstractVector) where {T<:Real}
  nlon, nlat, ntime = size(A)
  R = zeros(nlon, nlat) #.* T(NaN)

  @inbounds for i = 1:nlon, j = 1:nlat
    # ∑ = T(0)
    for k = 1:ntime
      xi = A[i, j, k]
      xi == xi && (R[i, j] += xi * w[i])
      # R[i, j] += xi == xi ? xi * w[i] : T(0)
    end
  end
  return R
end
