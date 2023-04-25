using LinearAlgebra
# https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/33

function valid_input(y::AbstractVector{T}, x::AbstractVector{T}) where {T<:Real}
  inds = @.(!isnan(y) && !isnan(x))

  y = @view y[inds]
  x = @view x[inds]
  x, y
end

# function linreg1(y, X)
#   β_hat = (X' * X) \ X' * y
#   return (β_hat)
# end

# function linreg2(y, X)
#   β_hat = X \ y
#   return (β_hat)
# end

"""
$(TYPEDSIGNATURES)
"""
function linreg_simple(y::AbstractVector{T}, x::AbstractVector{T}; na_rm=false) where {T<:Real}
  (length(x)) == length(y) || throw(DimensionMismatch())

  if na_rm
    y, x = valid_input(y, x)
  end

  x̄ = mean(x)
  ȳ = mean(y)

  sum_a = T(0.0)
  sum_b = T(0.0)
  @inbounds for i = 1:length(y)
    sum_a += (x[i] - x̄) * (y[i] - ȳ)
    sum_b += (x[i] - x̄) * (x[i] - x̄)
  end
  β1 = sum_a / sum_b
  β0 = ȳ - β1 * x̄
  # β1 = sum((x .- x̄) .* (y .- ȳ)) / sum((x .- x̄) .^ 2)
  [β0, β1]
end

function linreg_simple(y::AbstractVector{T}; kw...) where {T<:Real}
  x = T.(1:length(y))
  linreg_simple(y, x; kw...)
end


"""
$(TYPEDSIGNATURES)
"""
function linreg_fast(y::AbstractVector{T}, x::AbstractVector{T}; na_rm=false) where {T<:Real}
  (length(x)) == length(y) || throw(DimensionMismatch())
  
  if na_rm
    y, x = valid_input(y, x)
  end
  
  N = length(y)
  ldiv!(
    cholesky!(Symmetric([T(N) sum(x); zero(T) sum(abs2, x)], :U)),
    [sum(y), dot(x, y)])
end

function linreg_fast(y::AbstractVector{T}; kw...) where {T<:Real}
  x = T.(1:length(y))
  # need to skip nan values
  linreg_fast(y, x; kw...)
end


lm = linreg = linreg_fast
