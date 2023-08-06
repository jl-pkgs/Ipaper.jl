"""
    slope_p(y::AbstractVector, x::AbstractVector=1:length(y))

# Reference
1. https://zhuanlan.zhihu.com/p/642186978

# Example
```julia
x = [1, 2, 3, 4, 5];
y = [2, 4, 5, 4, 6];
slope_p(y)
```
"""
function Ipaper.slope_p(y::AbstractVector, x::AbstractVector=1:length(y); ignored...)
  n = length(x)
  df = n - 2

  covxy = cov(x, y)
  varx = var(x) # (x - mean(x))' * (x - mean(x)) / (n - 1)
  slope = covxy / varx
  resid = lm_resid(y, x)

  _var = sum((x .- mean(x)) .^ 2)
  resvar = sum(resid .^ 2) / df

  se = sqrt(resvar / _var)
  tval = slope / se
  pvalue = 2 * (1 - pt(abs(tval), df))

  # (; slope, se, tval, pvalue)
  # (; slope, pvalue) #, sd = se
  [slope, pvalue]
end

# function Ipaper.slope_mk(y::AbstractVector, x::AbstractVector=1:length(y); ci=0.95, ignored...)
#   r = mkTrend(y, x; ci)
#   (;slope = r.slope, pvalue = r.pvalue)
# end
