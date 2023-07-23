# function linreg1(y, X)
#   β_hat = (X' * X) \ X' * y
#   return (β_hat)
# end

# function linreg2(y, X)
#   β_hat = X \ y
#   return (β_hat)
# end

"""
    linreg_simple(y::AbstractVector, x::AbstractVector; na_rm=false) 
"""
function linreg_simple(y::AbstractVector, x::AbstractVector; na_rm=false) 
  (length(x)) == length(y) || throw(DimensionMismatch())

  if na_rm
    y, x = valid_input(y, x)
  end

  x̄ = mean(x)
  ȳ = mean(y)

  sum_a = 0.0
  sum_b = 0.0

  @inbounds for i = eachindex(y)
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
    linreg_fast(y::AbstractVector, x::AbstractVector; na_rm=false)
"""
function linreg_fast(y::AbstractVector, x::AbstractVector; na_rm=false) 
  (length(x)) == length(y) || throw(DimensionMismatch())
  
  if na_rm
    y, x = valid_input(y, x)
  end
  
  N = length(y)
  ldiv!(
    cholesky!(Symmetric([N sum(x); 0 sum(abs2, x)], :U)),
    [sum(y), dot(x, y)])
end

function linreg_fast(y::AbstractVector{T}; kw...) where {T<:Real}
  x = T.(1:length(y))
  # need to skip nan values
  linreg_fast(y, x; kw...)
end


function lm_resid(y::AbstractVector, x::AbstractVector)
  β0, β1 = linreg_simple(y, x)
  ysim = β0 .+ β1 .* x
  y .- ysim
end

lm = linreg = linreg_fast

export lm, linreg, linreg_fast, linreg_simple
export lm_resid
