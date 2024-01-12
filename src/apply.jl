"""
  $(TYPEDSIGNATURES)

# Arguments

- `dims_by`: if `by` provided, the length of `dims` should be one!
- `dims`: used by mapslices
- `combine`: if true, combine the result to a large array

# Examples
```julia
using Ipaper
using NaNStatistics
using Distributions

dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
yms = format.(dates, "yyyy-mm")

## example 01, some as R aggregate
x1 = rand(365)
apply(x1, 1, yms)
apply(x1, 1, by=yms)

## example 02
n = 100
x = rand(n, n, 365)

res = apply(x, 3, by=yms)
size(res) == (n, n, 12)

res = apply(x, 3)
size(res) == (n, n)

## example 03
dates = make_date(2010):Day(1):make_date(2013, 12, 31)
n = 10
ntime = length(dates)
x = rand(n, n, ntime, 13)

years = year.(dates)
res = apply(x, 3; by=years, fun=_nanquantile, combine=true, probs=[0.05, 0.95])
obj_size(res)

res = apply(x, 3; by=years, fun=nanmean, combine=true)
```
"""
function apply(x::AbstractArray, dims_by=3, args...; dims=dims_by, by=nothing, fun::Function=mean, combine=true, 
  parallel=false, progress=parallel, kw...)
  
  fun2(x) = fun(x, args...; kw...)
  
  if by === nothing
    ans = mapslices(fun2, x, dims=dims)
    # 除掉长度为1维度
    inds_bad = findall(size(ans) .== 1)
    length(inds_bad) >= 1 && (ans = dropdims(ans; dims=inds_bad[1]))
    res = ans
  else
    grps = unique(by)
    res = map(grp -> begin
        ind = by .== grp
        data = selectdim(x, dims_by, ind)
        # ans = fun(data, args...; kw...)
        ans = par_mapslices(fun2, data; dims, parallel, progress)
        inds_bad = findall(size(ans) .== 1)
        length(inds_bad) >= 1 && ndims(ans) > 1 && (ans = dropdims(ans; dims=inds_bad[1]))
        ans
      end, grps)
    # permutedims(A, perm)
    # ! may have bug
    along = size(res[1])[end] == 1 ? dims : ndims(res[1]) + 1
    combine && (res = cat(res..., dims=along))
  end
  res
end


export apply
