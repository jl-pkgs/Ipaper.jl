import NaNStatistics: _nanquantile!


# Quantile also works for missing 
"""
# Arguments
- `kw...`: other parameters to [`_quantile2`](@ref)
"""
function missQuantile(array::AbstractNanArray;
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=1)
  mapslices(x -> _quantile2(skipmissing(x), probs), array, dims=dims)
end

function missQuantile(array::AbstractArray{<:Real};
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=1, missval=nothing, kw...)

  if missval === nothing
    mapslices(x -> _quantile2(x, probs; kw...), array, dims=dims)
  else
    array = to_missing(array, missval)
    missQuantile(array; probs, dims)
  end
end
Quantile = missQuantile


function NaNStatistics._nanquantile!(q::AbstractVector, x::AbstractVector,
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1])

  for k = eachindex(probs)
    q[k] = NaNStatistics._nanquantile!(x, probs[k], (1,))[1]
  end
  q
end

# 针对性的写一个最高性能的Quantile
# 两次@view的嵌套会导致速度变慢；避免这种操作，可以获得极致的速度
"""
# Arguments

- `fun`: reference function, `quantile!` or `_nanquantile!`
"""
function nanQuantile!(q::AbstractArray{<:Real,3}, x::AbstractArray{<:Real,3};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3, na_rm::Bool=true)

  # println("3d is running!")
  fun = na_rm ? _nanquantile! : Statistics.quantile!
  # ntime = size(x, dims)
  nrow, ncol, ntime = size(x)
  nprob = length(probs)
  zi = zeros(eltype(x), ntime)
  _qi = zeros(eltype(x), nprob)

  @inbounds for i in 1:nrow, j = 1:ncol
    for t = eachindex(zi)
      zi[t] = x[i, j, t]
    end
    fun(_qi, zi, probs)
    for k = 1:nprob
      q[i, j, k] = _qi[k]
    end
  end
  q
end


function nanQuantile(x::AbstractArray{<:Real,3};
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3,
  na_rm::Bool=true, type=nothing)

  type = type === nothing ? eltype(x) : type
  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(type, Size...)
  nanQuantile!(q, x; probs, dims, na_rm)
end


"""
  $(TYPEDSIGNATURES)

# Examples
```julia
using Test

dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
ntime = length(dates)
arr = rand(Float32, 140, 80, ntime)
arr2 = copy(arr)

# default `na_rm=true`
@test nanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]

@time r1 = nanquantile(arr, dims=3) # low version
# 16.599892 seconds (56 allocations: 563.454 MiB, 2.18% gc time)
@time r2 = nanQuantile(arr; dims=3, na_rm=false)
@time r3 = nanQuantile(arr; dims=3, na_rm=true)

@test r1 == r2
@test r2 == r3
@test arr2 == arr
```

!!!`nanQuantile, na_rm=true` is 3 times faster than `nanquantile`
"""
function nanQuantile(x::AbstractArray;
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3,
  na_rm::Bool=true, type=nothing)

  # println("nd is running!")
  type = type === nothing ? eltype(x) : type
  fun = na_rm ? _nanquantile! : quantile!
  ntime = size(x, dims)
  nprob = length(probs)
  zi = zeros(eltype(x), ntime)
  qi = zeros(type, nprob)

  mapslices(xi -> begin
      for t = eachindex(zi)
        zi[t] = xi[t]
      end
      fun(qi, zi, probs)
    end, x; dims=dims)
end


## LOW EFFICIENT VERSION -------------------------------------------------------
"""
  nanquantile(x::AbstractArray{T,N}, probs::Vector{<:Real}; 
    dims::Integer=1, type = Float64) where {T,N}

# Examples
```julia
x = rand(4, 4, 201);
probs = [0.9, 0.99, 0.9999]

r = nanquantile(x; probs, dims=3);
r1 = nanQuantile(x; probs, dims=3);
r2 = missQuantile(x; probs, dims=3);

r == r1
r == r2
```
"""
function nanquantile!(q::AbstractArray{T}, x::AbstractArray{T,N};
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1], dims::Integer=1) where {T,N}

  xₜ = copyto!(Array{T,N}(undef, size(x)), x)
  for k = 1:length(probs)
    p = probs[k]
    selectdim(q, dims, k) .= _nanquantile!(xₜ, p, dims)
  end
  q
end

function nanquantile(x::AbstractArray;
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1], dims=1, type=nothing)

  type = type === nothing ? eltype(x) : type
  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(type, Size...)
  nanquantile!(q, x; probs, dims)
end


Base.isnan(x::AbstractArray) = isnan.(x)

all_isnan(x::AbstractArray) = all(isnan(x))
any_isnan(x::AbstractArray) = any(isnan(x))


export isnan, all_isnan, any_isnan,
  missQuantile,
  nanQuantile!, nanQuantile, _nanquantile!, nanQuantile2,
  nanquantile!, nanquantile
