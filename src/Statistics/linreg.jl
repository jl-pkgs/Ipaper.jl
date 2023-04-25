using LinearAlgebra
# https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/33

# function linreg1(y, X)
#   β_hat = (X' * X) \ X' * y
#   return (β_hat)
# end

# function linreg2(y, X)
#   β_hat = X \ y
#   return (β_hat)
# end
function linreg_simple(y::AbstractVector{T}, x::AbstractVector{T}) where {T<:Real}
  (N = length(x)) == length(y) || throw(DimensionMismatch())

  x̄ = mean(x)
  ȳ = mean(y)

  sum_a = T(0.0)
  sum_b = T(0.0)
  @inbounds for i = 1:N
    sum_a += (x[i] - x̄) * (y[i] - ȳ)
    sum_b += (x[i] - x̄) * (x[i] - x̄)
  end
  β1 = sum_a / sum_b
  β0 = ȳ - β1 * x̄
  # β1 = sum((x .- x̄) .* (y .- ȳ)) / sum((x .- x̄) .^ 2)
  [β0, β1]
end

function linreg_simple(y::AbstractVector{T}) where {T<:Real}
  x = Float32.(1:length(y))
  linreg_simple(y, x)
end



function linreg_fast(y::AbstractVector{T}, x::AbstractVector{T}) where {T<:Real}
  (N = length(x)) == length(y) || throw(DimensionMismatch())
  ldiv!(
    cholesky!(Symmetric([T(N) sum(x); zero(T) sum(abs2, x)], :U)),
    [sum(y), dot(x, y)])
end

function linreg_fast(y::AbstractVector{T}) where {T<:Real}
  x = Float32.(1:length(y))
  linreg_fast(y, x)
end


lm = linreg_fast 
