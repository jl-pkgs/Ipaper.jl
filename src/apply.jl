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

res = apply(x, 3; by=years, fun=mean, combine=true)

apply(x, 3; by = month.(dates), fun=slope_mk)
```
"""
function apply(A::AbstractArray, dims_by=3, args...; dims=dims_by,
  by=nothing, fun::Function=mean, combine=true,
  parallel=false, progress=parallel, kw...)

  fun2(x) = fun(x, args...; kw...)

  if by === nothing
    res = mapslices(fun2, A, dims=dims) |> _dropdims
  else
    grps = unique(by) |> sort
    res = par_map(grp -> begin
        ind = findall(by .== grp)
        data = selectdim(A, dims_by, ind) # |> collect
        # ans = fun(data, args...; kw...)
        # ans = par_mapslices(fun2, data; dims, parallel, progress)
        mapslices(fun2, data; dims) |> _dropdims # map slice is low efficient
      end, grps; parallel, progress)
    if combine
      # res = abind(res; increase=true)
      r = res[1]
      along = size(r)[end] == 1 ? dims_by : ndims(r) + 1
      res = cat(res..., dims=along)
    end
  end
  return res
end


function _dropdims(A::AbstractArray)
  inds1 = findall(size(A) .== 1)
  1 <= length(inds1) < ndims(A) && (A = dropdims(A; dims=inds1[1]))
  return A
end

export apply
