import NaNStatistics: _nanquantile!
import Statistics: quantile!
using Base: _unsafe_getindex!, _unsafe_setindex!, Slice

include("quantile_base.jl")


# 至强版NanQuantile!, 适用于任何多维array
function NanQuantile!(R::AbstractArray{<:Real,N}, A::AbstractArray{<:Real,N};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3, na_rm::Bool=true) where {N}

  fun = na_rm ? _nanquantile! : quantile!
  itershape = ntuple(d -> d in dims ? Base.OneTo(1) : axes(A, d), ndims(A))
  inds = CartesianIndices(itershape)

  dim_mask = ntuple(d -> d in dims, ndims(A))

  # intermediate variables
  ntime = size(A, dims)
  nprob = length(probs)
  Aslice = zeros(eltype(A), ntime)
  r = zeros(eltype(A), nprob)

  _Slice_A = Slice.(axes(A))
  _Slice_R = Slice.(axes(R))

  # idx = Vector{Any}(nothing, ndims(A))
  # ridx = Vector{Any}(nothing, ndims(R))
  @inbounds for I in inds
    # for k in eachindex(dim_mask)
    #   idx[k] = dim_mask[k] ? _Slice_A[k] : I[k]
    #   ridx[k] = dim_mask[k] ? _Slice_R[k] : I[k]
    # end
    idx = ifelse.(dim_mask, _Slice_A, Tuple(I))
    ridx = ifelse.(dim_mask, _Slice_R, Tuple(I))
    _unsafe_getindex!(Aslice, A, idx...)
    fun(r, Aslice, probs)
    R[ridx...] = r
  end
  R
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

@time r0 = nanquantile(arr, dims=3) # low version
@time r2_0 = NanQuantile(arr; dims=3, na_rm=false)
@time r2_1 = NanQuantile(arr; dims=3, na_rm=true)

@test r2_0 == r2_1
@test r2_0 == 20
@test arr2 == arr
```

!!!`NanQuantile(na_rm=true)` is 3~4 times faster than `nanquantile(na_rm=true)`
"""
function NanQuantile(A::AbstractArray{<:Real};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3, na_rm::Bool=true, dtype=nothing)

  dtype = dtype === nothing ? eltype(A) : dtype
  Size = size(A) |> collect
  Size[dims] = length(probs)
  R = zeros(dtype, Size...)
  NanQuantile!(R, A; probs, dims, na_rm)
end


# 二者性能相当
function nanQuantile(x::AbstractArray;
  probs=[0, 0.25, 0.5, 0.75, 1], dims::Integer=3,
  na_rm::Bool=true, dtype=nothing)

  dtype = dtype === nothing ? eltype(x) : dtype
  fun! = na_rm ? _nanquantile! : quantile!
  ntime = size(x, dims)
  nprob = length(probs)
  zi = zeros(eltype(x), ntime)
  qi = zeros(dtype, nprob)

  mapslices(xi -> begin
      for t = eachindex(zi)
        zi[t] = xi[t]
      end
      fun!(qi, zi, probs)
    end, x; dims=dims)
end
