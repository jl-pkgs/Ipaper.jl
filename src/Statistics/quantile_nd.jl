import NaNStatistics
# : _nanquantile!

function _nanquantile!(q::AbstractVector, x::AbstractVector, 
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

- `fun`: reference function, `Statistics.quantile!` or `_nanquantile!`
"""
function quantile_3d!(q::AbstractArray, x::AbstractArray;
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3, fun::Function=Statistics.quantile!)
  # @assert length(dims) == 1 "The length of `dims` should be 1!"
  # @show probs, dims
  ntime = size(x, dims)
  nrow, ncol, ntime = size(x)
  zi = zeros(eltype(x), ntime)
  nprob = length(probs)
  _qi = zeros(eltype(x), nprob)

  @inbounds for i in 1:nrow, j = 1:ncol
    for t = eachindex(zi)
      zi[t] = x[i, j, t]
    end
    # qi = @view q[i, j, :]
    # xi = @view x[i, j, :]
    # copy!(zi, xi) # copy xi to zi
    fun(_qi, zi, probs)
    for k = 1:nprob
      q[i, j, k] = _qi[k]
    end
  end
  q
end

function quantile_3d(x::AbstractArray; probs=[0, 0.25, 0.5, 0.75, 1], dims=3, type=nothing, kw...)
  type = type === nothing ? eltype(x) : type
  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(type, Size...)
  quantile_3d!(q, x; probs, dims, kw...)
end

# `nanquantile` is 3 times faster
function nanquantile_3d(x::AbstractArray; fun::Function=_nanquantile!, kw...)
  quantile_3d(x; fun=fun, kw...)
end

function quantile_nd(x::AbstractArray, probs=[0, 0.25, 0.5, 0.75, 1]; dims=3)
  # @assert length(dims) == 1 "The length of `dims` should be 1!"
  ntime = size(x, dims)
  zi = zeros(eltype(x), ntime)
  mapslices(xi -> begin
      for t = eachindex(zi)
        zi[t] = xi[t]
      end
      # copy!(zi, xi) # copy xi to zi
      Statistics.quantile!(zi, probs)
    end, x; dims=dims)
end


## NAN values quantiles --------------------------------------------------------
"""
  nanquantile(x::AbstractArray{T,N}, probs::Vector{<:Real}; 
    dims::Integer=1, type = Float64) where {T,N}

# Examples
```julia
x = rand(4, 4, 201);
probs = [0.9, 0.99, 0.9999]

r1 = Quantile(x, probs, dims=3);
r2 = nanquantile(x; probs, dims=3);
```
"""
function nanquantile!(q::AbstractArray{T}, x::AbstractArray{T,N};
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1], dims::Integer=1) where {T,N}

  xₜ = copyto!(Array{T,N}(undef, size(x)), x)
  for k = 1:length(probs)
    p = probs[k]
    selectdim(q, dims, k) .= NaNStatistics._nanquantile!(xₜ, p, dims)
  end
  q
end

function nanquantile(x::AbstractArray;
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1], dims=1, type=nothing)

  type = type === nothing ? eltype(x) : type

  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(type, Size...)
  nanquantile!(q, x; probs=probs, dims=dims)
end


Base.isnan(x::AbstractArray) = isnan.(x)

all_isnan(x::AbstractArray) = all(isnan(x))
any_isnan(x::AbstractArray) = any(isnan(x))


export isnan, all_isnan, any_isnan,
  _nanquantile!,
  quantile_3d, nanquantile_3d
