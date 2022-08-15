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
