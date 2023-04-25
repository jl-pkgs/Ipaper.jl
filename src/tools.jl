import StatsBase: weights, mean, quantile
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


r_summary(x; digits=2) = nothing
function r_summary(x::AbstractArray{<:Real}; digits=2)
  T = eltype(x)
  probs = [0, 0.25, 0.5, 0.75, 1]

  x2 = filter(!isnan, x)
  if (length(x2) == 0)
    printstyled("empty array"; color=:red)
    return
  end

  n_nan = length(x) - length(x2)
  r = quantile(x2, probs)
  insert!(r, 4, mean(x2))
  r = round.(r, digits=digits)
  
  printstyled("Min\t 1st.Qu\t Median\t Mean\t 3rd.Qu\t Max\t NA's\n"; color=:blue)
  printstyled("$(r[1])\t $(r[2])\t $(r[3])\t $(r[4])\t $(r[5])\t $(r[6])\t $(n_nan)"; color=:blue)
  nothing
end



export which_isna, which_notna, 
    is_empty, not_empty,
    mean, weighted_mean, weighted_sum,
    seq_along, seq_len,
    Range,
    set_seed;
export isnan, all_isnan, any_isnan;
export obj_size, r_summary
