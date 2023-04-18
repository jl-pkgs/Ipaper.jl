import StatsBase: weights, mean
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


# TODO: need to test
function CartesianIndex2Int(x, ind)
    # I = 1:prod(size(x))
    I = LinearIndices(x)
    I[ind]
end



seq_along(x) = 1:length(x)
seq_len(n) = 1:n

Range(x) = [minimum(x), maximum(x)]


function obj_size(x)
  ans = Base.summarysize(x) / 1024^2
  ans = round(ans, digits=2)
  print(typeof(x), " | ", size(x), " | ")
  printstyled("$ans Mb"; color=:blue, bold=true, underline=true)
end


export which_isna, which_notna, 
    is_empty, not_empty,
    mean, weighted_mean, weighted_sum,
    seq_along, seq_len,
    Range,
    set_seed;
export isnan, all_isnan, any_isnan;
export obj_size
