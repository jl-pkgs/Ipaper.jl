function NanQuantile_low!(R::AbstractArray{<:Real,N}, A::AbstractArray{<:Real,N};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N, na_rm::Bool=true) where {N}

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
    NanQuantile_low(A::AbstractArray{T,N};
        probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N, na_rm::Bool=true, dtype=nothing) where {T<:Real,N}

`NanQuantile_low(na_rm=rue)` is 3~4 times faster than `_nanquantile(na_rm=true)`

# Examples

```julia
using Test

dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
ntime = length(dates)
arr = rand(Float32, 140, 80, ntime)
arr2 = copy(arr)

# default `na_rm=true`
@test NanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]

@time r0 = _nanquantile(arr, dims=3) # low version
@time r2_0 = NanQuantile_low(arr; dims=3, na_rm=false)
@time r2_1 = NanQuantile_low(arr; dims=3, na_rm=true)

@test r2_0 == r2_1
@test r2_0 == 20
@test arr2 == arr
```
"""
function NanQuantile_low(A::AbstractArray{T,N};
  probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N, na_rm::Bool=true, dtype=nothing) where {T<:Real,N}

  dtype = dtype === nothing ? eltype(A) : dtype
  Size = size(A) |> collect
  Size[dims] = length(probs)
  R = zeros(dtype, Size...)
  NanQuantile_low!(R, A; probs, dims, na_rm)
end
