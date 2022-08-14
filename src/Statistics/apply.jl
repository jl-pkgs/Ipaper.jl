"""
  $(TYPEDSIGNATURES)

# Arguments

- `dims`: if `by` provided, the length of `dims` should be one!


# Examples
```julia
dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
n = 100
x = rand(n, n, 365)

ym = format.(dates, "yyyy-mm")
res = apply(x, 3, ym)
size(res) == (n, n, 12)

res = apply(x, 3)
size(res) == (n, n)
```
"""
function apply(x::AbstractArray, dims=3, by=nothing; fun::Function=mean)
  if by === nothing
    res = mapslices(fun, x, dims=dims)
    selectdim(res, dims, 1)
  else
    grps = unique(by)
    res = map(grp -> begin
        ind = by .== grp
        mapslices(fun, selectdim(x, dims, ind), dims=dims)
      end, grps)
    cat(res..., dims=dims)
  end
end
