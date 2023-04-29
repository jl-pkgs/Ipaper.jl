function NaNStatistics._nanquantile!(q::AbstractVector, x::AbstractVector,
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1])
  for k = eachindex(probs)
    q[k] = NaNStatistics._nanquantile!(x, probs[k], (1,))[1]
  end
  q
end

# 针对性的写一个最高性能的Quantile
# 两次@view的嵌套会导致速度变慢；避免这种操作，可以获得极致的速度

# 3d版本提速不大，意义不大
"""
# Arguments

- `fun`: reference function, `quantile!` or `_nanquantile!`
"""
function nanQuantile_3d!(q::AbstractArray{T,3}, x::AbstractArray{T,3};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], 
  # dims::Integer=3, 
  na_rm::Bool=true, ignored...) where {T<:Real}

  # println("3d is running!")
  fun! = na_rm ? _nanquantile! : Statistics.quantile!
  # ntime = size(x, dims)
  nrow, ncol, ntime = size(x)
  nprob = length(probs)
  _zi = zeros(T, ntime)
  _qi = zeros(T, nprob)
  
  # @inbounds 
  @inbounds for i = 1:nrow, j = 1:ncol
    for t = 1:ntime
      _zi[t] = x[i, j, t]
    end
    
    fun!(_qi, _zi, probs)
    for k = 1:nprob
      q[i, j, k] = _qi[k]
    end
  end
  q
end

function nanQuantile_3d(x::AbstractArray{<:Real,3};
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3,
  na_rm::Bool=true, dtype=nothing)

  dtype = dtype === nothing ? eltype(x) : dtype
  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(dtype, Size...)
  nanQuantile_3d!(q, x; probs, dims, na_rm)
end



## LOW EFFICIENT VERSION -------------------------------------------------------
"""
  nanquantile(x::AbstractArray{T,N}, probs::Vector{<:Real}; 
    dims::Integer=1, dtype = Float64) where {T,N}

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
  for k = eachindex(probs)
    p = probs[k]
    selectdim(q, dims, k) .= _nanquantile!(xₜ, p, dims)
  end
  q
end

function nanquantile(x::AbstractArray;
  probs::Vector{<:Real}=[0, 0.25, 0.5, 0.75, 1], dims=1, dtype=nothing)

  dtype = dtype === nothing ? eltype(x) : dtype
  Size = size(x) |> collect
  Size[dims] = length(probs)
  q = zeros(dtype, Size...)
  nanquantile!(q, x; probs, dims)
end


export
  missQuantile,
  nanQuantile,
  nanQuantile_3d, nanQuantile_3d!,
  nanquantile, nanquantile!
