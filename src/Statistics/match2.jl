# import StatsBase: countmap
# table = countmap
function dict2order(dict; rev=true, by_value=true)
  _keys = keys(dict) |> collect
  _values = values(dict) |> collect
  
  x = by_value ? _values : _keys
  inds = sortperm(x; rev)
  OrderedDict(_keys[i] => _values[i] for i in inds)
end

"""
  table(x::AbstractVector)

!Caution:
This function is about 5X slower than `StatsBase: countmap`.
If speed matters for you, use `StatsBase.countmap` instead.
"""
function table(x::AbstractVector; rev=false, by_value=false)
  tbl = Dict{eltype(x),Int}()
  for element in x
    if haskey(tbl, element)
      tbl[element] += 1
    else
      tbl[element] = 1
    end
  end
  return dict2order(tbl; rev, by_value)
end


"""
    match2(x, y)

# Examples
```julia
## original version
mds = [1, 4, 3, 5]
md = [1, 5, 6]

findall(r_in(mds, md))
indexin(md, mds)

## modern version
x = [1, 2, 3, 3, 4]
y = [0, 2, 2, 3, 4, 5, 6]
match2(x, y)
```

# Note: match2 only find the element in `y`
"""
function match2(x, y)
  # find x in y
  ind = indexin(x, y)
  I_x = which_notnull(ind)
  I_y = something.(ind[I_x])
  # use `something` to suppress nothing `Union`
  (; value=x[I_x], I_x, I_y)
end


unique_length(x) = length(unique(x))
uniqueN = unique_length

"""
    duplicated(x::Vector{<:Real})

```julia
x = [1, 2, 3, 4, 1]
duplicated(x)
# [0, 0, 0, 0, 1]
```
"""
function duplicated(x::AbstractVector)
  seen_elements = Dict{eltype(x),Bool}()
  result = falses(length(x))

  @inbounds for (i, element) in enumerate(x)
    if haskey(seen_elements, element)
      result[i] = true
    else
      seen_elements[element] = true
    end
  end
  return result
end


export match2, unique_length, duplicated,
  table, uniqueN
