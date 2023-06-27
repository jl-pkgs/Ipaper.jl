"""
  $(TYPEDSIGNATURES)

# Arguments

- `dims`: if `by` provided, the length of `dims` should be one!


# Examples
```julia
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
n = 100
ntime = length(dates)
x = rand(n, n, ntime)

years = year.(dates)
res = apply(x, 3; by=years, fun=nanquantile, combine=true, probs=[0.05, 0.95])
obj_size(res)

res = apply(x, 3; by=years, fun=nanmean, combine=true)
```
"""
function apply(x::AbstractArray, dims=3, args...; by=nothing, fun::Function=mean, combine=true, kw...)
  fun2(x) = fun(x, args...; kw...)

  if by === nothing
    res = mapslices(fun, x, dims=dims)
    res = selectdim(res, dims, 1)
  else
    grps = unique(by)
    res = map(grp -> begin
        ind = by .== grp
        data = selectdim(x, dims, ind)
        # ans = fun(data, args...; kw...)
        ans = mapslices(fun2, data, dims=dims)
        ans
      end, grps)
    # permutedims(A, perm)
    # may have bug
    along = size(res[1])[end] == 1 ? dims : ndims(res[1]) + 1
    combine && (res = cat(res..., dims=along))
  end
  res
end

apply(x::AbstractArray, dims, by; kw...) = apply(x, dims; by = by, kw...)
