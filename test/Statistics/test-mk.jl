using RCall
using Ipaper
using Distributions

n = 100
A = rand(n, n, 30)
obj_size(A)


## 1. 对比计算速度
## R is slow
@time r1 = R"""
library(rtrend)
library(Ipaper)

data = $A
n = dim(data)[1]
for (i in 1:n) {
  Ipaper::runningId(i, 50)
  for (j in 1:n) {
    y = data[i, j, ]
    rtrend::mkTrend(y)
  }
}
"""

# 203.661358 seconds (117.70 k allocations: 8.194 MiB, 0.04% compilation time)

function fun(A::AbstractArray)
  n, m = size(A)[1:2]
  @views @inbounds for i = 1:n, j = 1:m
    y = A[i, j, :]
    slope_mk(y)
  end
end

@time r2 = fun(A);
# 12.528963 seconds (25.88 M allocations: 15.108 GiB, 4.61% gc time)
# > 16 times faster

get_clusters()
@time r1 = mapslices(slope_mk, A; dims=3);
@time r2 = par_mapslices(slope_mk, A; dims=3);

# 3.744367 seconds (34.81 M allocations: 15.331 GiB, 37.76% gc time), the par version

r1 - r2
# maximum(abs.(r1 - r2))

## 2. 核验计算结果
y = rand(30)
slope_mk(y)
R"rtrend::slope_mk($y)"
