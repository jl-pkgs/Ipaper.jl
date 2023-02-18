import StatsBase: countmap, weights, mean
import Random: seed!

set_seed(seed) = seed!(seed)


# import Base: length
Base.length(x::Nothing) = 0
is_empty(x) = length(x) == 0
not_empty(x) = length(x) > 0


weighted_mean(x, w) = mean(x, weights(w))
weighted_sum(x, w) = sum(x, weights(w))


function nth(x, n)
    x = sort(x)
    x[n]
end

which_isna(x) = findall(x .== nothing)
which_notna(x) = findall(x .!= nothing)


Base.isnan(x::AbstractArray) = isnan.(x)

all_isnan(x::AbstractArray) = all(isnan(x))
any_isnan(x::AbstractArray) = any(isnan(x))


uniqueN(x) = length(unique(x))

# TODO: need to test
function CartesianIndex2Int(x, ind)
    # I = 1:prod(size(x))
    I = LinearIndices(x)
    I[ind]
end


table = countmap

"""
    duplicated(x::Vector{<:Real})

```julia
x = [1, 2, 3, 4, 1]
duplicated(x)
# [0, 0, 0, 0, 1]
```
"""
function duplicated(x::Vector)
    grps = table(x)
    grps = filter(x -> x[2] > 1, grps)

    n = length(x)
    res = BitArray(undef, n)
    res .= false
    for (key, freq) in grps
        k = 0
        for i = 1:n
            if x[i] == key
                k = k + 1
                if k >= 2
                    res[i] = true
                end
                if k == freq
                    break
                end
            end
        end
    end
    res
end

seq_along(x) = 1:length(x)
seq_len(n) = 1:n

Range(x) = [minimum(x), maximum(x)]

export table, which_isna, which_notna, match2, uniqueN, duplicated,
    is_empty, not_empty,
    mean, weighted_mean, weighted_sum,
    seq_along, seq_len,
    Range,
    set_seed;
export isnan, all_isnan, any_isnan;
