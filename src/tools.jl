import StatsBase: weights, mean, quantile
import Random: seed!
include("r_base.jl")


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

length_unique(x::AbstractVector) = length(unique(x))

unique_sort(x) = sort(unique(x))

seq_along(x) = seq_len(length(x))
seq_len(n) = 1:n

r_range(x) = [minimum(x), maximum(x)]


function obj_size(x)
  ans = Base.summarysize(x) / 1024^2
  ans = round(ans, digits=2)
  print(typeof(x), " | ", size(x), " | ")
  printstyled("$ans Mb\n"; color=:blue, bold=true, underline=true)
end


function squeeze_TailOrHead(A::AbstractArray; type="tail")
  dims = size(A)
  n = length(dims)

  dims_drop = []  
  if type == "head"
    inds = 1:n
  elseif type == "tail"
    inds = n:-1:1
  end
  
  for i = inds
    if dims[i] == 1
      push!(dims_drop, i)
    else
      break
    end
  end
  
  if !isempty(dims_drop)
    dropdims(A, dims=tuple(dims_drop...))
  else
    A
  end
end

squeeze_tail(A::AbstractArray) = squeeze_TailOrHead(A; type="tail")
squeeze_head(A::AbstractArray) = squeeze_TailOrHead(A; type="head")

function squeeze(A::AbstractArray)
  dropdims(A, dims=tuple(findall(size(A) .== 1)...))
end


function zip_continue(x::AbstractVector{<:Integer})
  flag = cumsum([true; diff(x) .!= 1])
  grps = unique(flag)
  n = grps[end]
  
  res = []
  for i = 1:n
    inds = findall(flag .== grps[i])
    index = [inds[1], inds[end]]
    push!(res, (; grp=i, index, value=x[index]))
  end
  res
end


# using Interpolations
# function approx(x, y, xout)
#   interp_linear_extrap = linear_interpolation(x, y, extrapolation_bc=Line())
#   interp_linear_extrap.(xout) # outside grid: linear extrapolation
# end

function meshgrid(x, y)
  X = repeat(x', length(y), 1)
  Y = repeat(y, 1, length(x))
  X, Y
end

array(val; dims) = reshape(val, dims...)
array(val, dims) = array(val; dims)

function abind(x::AbstractVector, dim=3)
  cat(x..., dims=dim)
end


function selectdim_deep(A, dims::Integer, i; deep=true)
  if deep
    inds = ntuple(d -> d in dims ? i : (:), ndims(A))
    A[inds...]
  else
    selectdim(A, dims, i)
  end
end


export which_isna, which_notna,
  is_empty, not_empty,
  mean, weighted_mean, weighted_sum,
  seq_along, seq_len,
  r_range,
  nth, 
  selectdim_deep,
  length_unique, unique_sort, 
  squeeze, squeeze_tail, squeeze_head,
  abind,
  set_seed;
export isnan, all_isnan, any_isnan;
export obj_size, r_summary, r_split
export zip_continue
