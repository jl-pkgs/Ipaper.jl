import Random: seed!
include("r_base.jl")

# for quarto
include2(f) = include("$(pwd())/$(basename(f))")
# includet2(f) = includet("$(pwd())/$(basename(f))")

set_seed(seed) = seed!(seed)

# import Base: length
Base.length(x::Nothing) = 0
is_empty(x) = length(x) == 0
not_empty(x) = length(x) > 0


function nth(x, n)
  x = sort(x)
  x[n]
end

which_isnull(x) = findall(x .== nothing)
which_notnull(x) = findall(x .!= nothing)

which_isnan(x) = findall(isnan.(x))
which_notnan(x) = findall(.!isnan.(x))

# Base.isnan(x::AbstractArray) = isnan.(x)
all_isnan(x::AbstractArray) = all(isnan.(x))
any_isnan(x::AbstractArray) = any(isnan.(x))


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


"""
    obj_size(x)
    obj_size(dims, T)

# Examples
```julia
dims = (100, 100, 200)
x = zeros(Float32, dims)
obj_size(x)
obj_size(dims, Float32)
```
"""
function obj_size(x)
  ans = Base.summarysize(x) / 1024^2
  ans = round(ans, digits=2)
  print(typeof(x), " | ", size(x), " | ")
  printstyled("$ans Mb\n"; color=:blue, bold=true, underline=true)
end

function obj_size(dims, T)
  ans = Base.summarysize(T(0)) * prod(dims) / 1024^2
  ans = round(ans, digits=2)
  print(T, " | ", dims, " | ")
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

# function abind(x::AbstractVector, dim=3)
#   cat(x..., dims=dim)
# end
# abind(args...; along=3) = cat(args..., dims=along)
"""
    abind(args; along=nothing, increase=true)

# Arguments
- `increase`: 
  If along is not specified.
  + `false`: cat along the last dim
  + `true`: cat along the last dim + 1
"""
function abind(args; along=nothing, increase=true)
  if along === nothing 
    n = ndims(args[1])
    along = increase ? n + 1 : n
  end
  cat(args..., dims=along)
end

function selectdim_deep(A, dims::Integer, i; deep=true)
  if deep
    inds = ntuple(d -> d in dims ? i : (:), ndims(A))
    A[inds...]
  else
    selectdim(A, dims, i)
  end
end


# findnear(x::Real, vals::AbstractVector) = argmin(abs.(vals .- x))
# function findnear(x::Real, y::Real, lon::AbstractVector, lat::AbstractVector)
#   i = findnear(x, lon)
#   j = findnear(y, lat)
#   return i, j
# end
function findnear(x::Real, vals::AbstractVector; cell::Real=NaN, tol=1e-2)
  diff = abs.(vals .- x)
  i = argmin(diff)
  isnan(cell) && return i
  diff[i] <= (0.5+tol)*abs(cell) ? i : -1 # 在1个网格内
end

# cellsize需要是准确的
function findnear((x, y)::Tuple{Real,Real}, lon::AbstractVector, lat::AbstractVector;
  cellx::Real=NaN, celly::Real=NaN, tol=1e-2)
  i = findnear(x, lon; cell=cellx, tol)
  j = findnear(y, lat; cell=celly, tol)
  (i == -1 || j == -1) && (return nothing)
  return i, j
end

findnear(x::Real, y::Real, lon::AbstractVector, lat::AbstractVector; cellx::Real=NaN, celly::Real=NaN, tol=1e-2) = 
  findnear((x, y), lon, lat; cellx, celly, tol)

export which_isnull, which_notnull,
  which_isnan, which_notnan,
  is_empty, not_empty,
  seq_along, seq_len,
  r_range,
  nth,
  selectdim_deep,
  length_unique, unique_sort,
  squeeze, squeeze_tail, squeeze_head,
  abind, 
  findnear,
  set_seed;
export array
export isnan, all_isnan, any_isnan;
export obj_size, r_summary, r_split
export zip_continue
export include2
