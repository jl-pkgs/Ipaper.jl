# using LoopVectorization
weighted_mean(x::AbstractVector, w::AbstractVector) = sum(x .* w) / sum(w)

function weighted_nanmean(x::AbstractVector{T1}, w::AbstractVector{T2}) where {T1,T2}
  T = promote_type(T1, T2)
  ∑ = ∅ = T(0)
  ∑w = ∅w = T2(0)

  @inbounds for i = eachindex(x)
    xᵢ = x[i]
    notnan = xᵢ == xᵢ
    ∑ += ifelse(notnan, x[i] * w[i], ∅)
    ∑w += ifelse(notnan, w[i], ∅w)
  end
  return ∑ / ∑w
end
