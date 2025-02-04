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

export approx
