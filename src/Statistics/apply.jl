"""
  $(TYPEDSIGNATURES)

# Arguments

- `dims`: if `by` provided, the length of `dims` should be one!


# Examples
```julia
dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
yms = format.(dates, "yyyy-mm")

## example 01
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
```
"""
function apply(x::AbstractArray, dims=3; by=nothing, fun::Function=mean)
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

apply(x::AbstractArray, dims, by; kw...) = apply(x, dims; by = by, kw...)
