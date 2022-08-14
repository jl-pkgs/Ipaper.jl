using Ipaper
using BenchmarkTools

arr = rand(10, 10, 365 * 10);
_arr = deepcopy(arr);

@btime r1 = Quantile($arr, dims=3);
@btime r2 = Quantile2($arr, dims=3);

@time r1 = Quantile(arr, dims=3);
@time r2 = Quantile2(arr, dims=3);

r1 == r2
arr == _arr

# x = ones(4)
# y = Base.copymutable(x)
# y[1] = 4
# y
# x


using Random

begin
  Random.seed!(1)
  x = rand(100)

  r1 = quantile!(x, 0.5; sorted=true) # 第一种求解是错误的
  r2 = quantile!(x, 0.5)

  @show r1
  @show r2
  x
end

import Statistics
# 节省zi的开支


# y = zeros(3)
# quantile!(y, x, [0.1, 0.5, 0.9]) === y

