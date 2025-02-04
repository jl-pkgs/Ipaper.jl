import StatsBase: rle, inverse_rle
import Dates: DateTime, datetime2unix
# import Interpolations: linear_interpolation, Line
# function approx(x, y, xout)
#   interp_linear_extrap = linear_interpolation(x, y, extrapolation_bc=Line())
#   interp_linear_extrap.(xout) # outside grid: linear extrapolation
# end
export find_first, interp_linear

function find_first(x::AbstractVector, xout::Real)
  # `x` should be sorted
  direct = sign(x[2] - x[1])
  if direct == 1
    searchsortedlast(x, xout)
  elseif direct == -1
    searchsortedlast(x, xout; lt=Base.isgreater)
  end
end

function interp_linear(x1::Real, y1::Real, x2::Real, y2::Real, xout::Real)
  y1 + (xout - x1) * (y2 - y1) / (x2 - x1)
end

# xi需要提前体现排序才能得到正确的结果
"""
    approx(x, y, xout; rule=2)

Approximate the value of a function at a given point using linear interpolation.
> `DateTime` is also supported. But `Date` not!

# Arguments
- `x::AbstractVector{Tx}`: The x-coordinates of the data points.
- `y::AbstractVector{Ty}`: The y-coordinates of the data points.
- `xout::AbstractVector`: The x-coordinates of the points to approximate.
- `rule::Int=2`: The interpolation rule to use. Default is 2.
  + 1: NaN
  + 2: nearest constant extrapolation
  + 3: linear extrapolation
"""
function approx(x::AbstractVector{Tx}, y::AbstractVector{Ty}, xout::AbstractVector; rule=2) where {Tx<:Real,Ty<:Real}
  yout = similar(xout, Ty)

  ## fix for random order in `x`
  if !(issorted(x) || issorted(x, rev=true))
    inds = sortperm(x)
    x = x[inds]
    y = y[inds]
  end
  NA = Ty(NaN)
  
  @inbounds for (i, xi) in enumerate(xout)
    # Find the interval that xi falls in
    idx = find_first(x, xi)
    # If xi is out of bounds of x, extrapolate
    if idx == 0 # 首
      rule == 1 && (yout[i] = NA)
      rule == 2 && (yout[i] = y[1])
      rule == 3 && (yout[i] = interp_linear(x[1], y[1], x[2], y[2], xi))
    elseif idx == length(x) # 尾
      rule == 1 && (yout[i] = NA)
      rule == 2 && (yout[i] = y[end])
      rule == 3 && (yout[i] = interp_linear(x[end-1], y[end-1], x[end], y[end], xi))
    else # 正常
      yout[i] = interp_linear(x[idx], y[idx], x[idx+1], y[idx+1], xi)
    end
  end
  return yout
end


approx(x::AbstractVector{DateTime}, y::AbstractVector, xout::AbstractVector{DateTime}; rule=2) =
  approx(datetime2unix.(x), y, datetime2unix.(xout); rule)

approx(x::AbstractVector{Date}, y::AbstractVector, xout::AbstractVector{Date}; rule=2) =
  approx(DateTime.(x), y, DateTime.(xout); rule)


"""
    findnan(y::AbstractVector; maxgap::Int=Inf)

Find the indices of `NaN` values in the vector `y`, but only if the run of `NaN`s is less than or equal to `maxgap`.

# Arguments
- `y::AbstractVector`: The input vector to search for `NaN` values.
- `maxgap::Int=Inf`: The maximum allowed length of consecutive `NaN` values to be included in the result. Runs of `NaN`s longer than this will be ignored.

# Returns
- `Vector{Int}`: A vector of indices where `NaN` values are found, considering the `maxgap` constraint.

# Example
```julia
y = [1.0, NaN, NaN, 4.0, NaN, NaN, NaN, 8.0]
findnan(y, maxgap=2) # returns [2, 3]
findnan(y, maxgap=3) # returns [2, 3, 5, 6, 7]
```
"""
function findnan(y::AbstractVector; maxgap::Real=Inf)
  lgl = isnan.(y)
  vals, lens = rle(lgl)
  for i in eachindex(vals)
    if vals[i] == true && lens[i] > maxgap
      vals[i] = false
    end
  end
  lgl2 = inverse_rle(vals, lens)
  findall(lgl2)
end

## na_approx
function na_approx!(x::AbstractVector, y::AbstractVector; maxgap::Real=Inf, rule=2)
  lgl = .!isnan.(y)
  inds_na = findnan(y; maxgap)
  isempty(inds_na) && return y
  y[inds_na] = approx(x[lgl], y[lgl], x[inds_na]; rule=2) # also modify `y`
  return y
end
na_approx(x::AbstractVector, y::AbstractVector; maxgap::Real=Inf, rule::Int=2) = na_approx!(x, deepcopy(y); maxgap, rule)

na_approx!(y::AbstractVector; maxgap::Real=Inf, rule::Int=2) = na_approx!(eachindex(y), y; maxgap, rule)
na_approx(y::AbstractVector; maxgap::Real=Inf, rule::Int=2) = na_approx!(deepcopy(y); maxgap, rule)


export approx
export findnan, na_approx, na_approx!
