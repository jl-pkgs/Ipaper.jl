function _slope_sen(y::AbstractVector, x::AbstractVector=1:length(y))
  n = length(x)
  V = fill(NaN, Int((n^2 - n) / 2))
  k = 0
  for i in 2:n
    for j in 1:(i-1)
      k += 1
      V[k] = (y[i] - y[j]) / (x[i] - x[j])
    end
  end
  median(V)
end


"""
    trend_mk(y::AbstractVector{T}; ci=0.95) where {T<:Real}

# Arguments

- `y`: numeric vector
- `x`: (optional) numeric vector
- `ci`: critical value of autocorrelation

# Return

- `Z0`    : The original (non corrected) Mann-Kendall test Z statistic.

- `pval0` : The original (non corrected) Mann-Kendall test p-value

- `Z`     : The new Z statistic after applying the correction

- `pval`  : Corrected p-value after accounting for serial autocorrelation
  `N/n*s` Value of the correction factor, representing the quotient of the
  number of samples N divided by the effective sample size `n*s`

- `slp`   : Sen slope, The slope of the (linear) trend according to Sen test.
  slp is significant, if pval < alpha.

# References

1. Hipel, K.W. and McLeod, A.I. (1994), Time Series Modelling of Water
   Resources and Environmental Systems. New York: Elsevier Science.

2. Libiseller, C. and Grimvall, A., (2002), Performance of partial Mann-Kendall
   tests for trend detection in the presence of covariates.
   Environmetrics, 13, 71--84, doi:10.1002/env.507.

# Example
```julia
julia> mkTrend([4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69])
(z0 = 0.35777087639996635, pval0 = 0.7205147871362552, z = 0.35777087639996635, pval = 0.7205147871362552, slope = 0.040000000000000036, intercept = 4.441)
```
"""
function Ipaper.slope_mk(y::AbstractVector, x::AbstractVector=1:length(y); ci=0.95)
  z0 = z = pval0 = pval = slp = intercept = NaN

  # y = dropmissing(y)
  n = length(y)
  if n < 5
    return (; z0, pval0, z, pval, slp, intercept)
  end
  
  S = 0
  for i in 1:(n-1)
    for j in (i+1):n
      S += sign(y[j] - y[i])
    end
  end
  
  sig = quantile(Normal(), (1 + ci) / 2) / sqrt(n) # qnorm((1 + ci)/2)/sqrt(n)

  rank = tiedrank(lm_resid(y, 1:n))
  ro = autocor(rank, 1:n-1)
  ro[abs.(ro) .<= sig] .= 0.0 # modified by dongdong Kong, 2017-04-03
  
  cte = 2 / (n * (n - 1) * (n - 2))

  ess = 0.0
  for i in 1:n-1
    ess += (n - i) * (n - i - 1) * (n - i - 2) * ro[i]
  end

  essf = 1 + ess * cte
  var_S = n * (n - 1) * (2n + 5) * (1.0 / 18)
  
  if length(unique(y)) < n
    aux = unique(y)
    for i in eachindex(aux)
      tie = count(y .== aux[i])
      if tie > 1
        var_S -= tie * (tie - 1) * (2tie + 5) * (1 / 18)
      end
    end
  end

  VS = var_S * essf
  if S == 0
    z = 0.0
    z0 = 0.0
  elseif S > 0
    z = (S - 1) / sqrt2(VS)
    z0 = (S - 1) / sqrt(var_S)
  else
    z = (S + 1) / sqrt2(VS)
    z0 = (S + 1) / sqrt(var_S)
  end

  # pvalue0 = 2 * pnorm(-abs(z0))
  pvalue = 2 * pnorm(-abs(z))
  # Tau = S / (0.5 * n * (n - 1))
  slope = _slope_sen(y, x)
  intercept = mean(y .- slope .* (1:n))

  [slope, pvalue]
  # (; slope, pvalue, z, pvalue0, z0, intercept)
end
