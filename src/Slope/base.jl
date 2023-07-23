using LinearAlgebra
# https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/33

function valid_input(y::AbstractVector, x::AbstractVector) 
  inds = @.(!isnan(y) && !isnan(x))

  y = @view y[inds]
  x = @view x[inds]
  x, y
end


