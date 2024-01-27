import StatsBase: countmap
table = countmap


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
function duplicated(x::Vector)
  grps = filter(x -> x[2] > 1, table(x))

  n = length(x)
  res = BitArray(undef, n)
  res .= false
  for (key, freq) in grps
    k = 0
    for i = 1:n
      if x[i] == key
        k = k + 1
        k >= 2 && (res[i] = true)
        k == freq && break
      end
    end
  end
  res
end



export match2, unique_length, duplicated,
  table, uniqueN
