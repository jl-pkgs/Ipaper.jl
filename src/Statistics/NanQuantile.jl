import Statistics: quantile!
using Base: _unsafe_getindex!, _unsafe_setindex!, Slice

include("quantile_base.jl")
include("NanQuantile_low.jl")

# `NanQuantile`与`NanQuantile_low`性能相当
function NanQuantile(x::AbstractArray{T,N};
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N,
  na_rm::Bool=true, dtype=nothing, use_zi=true) where {T<:Real, N}

  dtype = dtype === nothing ? T : dtype
  fun! = na_rm ? _nanquantile! : quantile!
  
  qi = zeros(dtype, length(probs))

  if use_zi
    ntime = size(x, dims)
    zi = zeros(eltype(x), ntime)
    
    mapslices(xi -> begin
        copyto!(zi, xi)
        fun!(qi, zi, probs)
      end, x; dims=dims)
  else
    mapslices(xi -> fun!(qi, xi, probs), x; dims=dims)
  end
end

function NanQuantile(x::AbstractArray{T,N}, probs;
  dims::Integer=N, na_rm::Bool=true, dtype=nothing) where {T<:Real, N}
  
  NanQuantile(x; probs, dims, na_rm, dtype)
end
