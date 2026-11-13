export par_mapslices

import Base.Threads
import Base: Slice, concatenate_setindex!

# Build the index tuple for a slice.
# Using @generated with Val{mask} avoids Union-typed tuples from ifelse.() broadcast,
# eliminating per-iteration heap allocations and enabling type-stable view/setindex.
@generated function _make_slice_idx(::Val{mask}, slice_A, I) where {mask}
  N = length(mask)
  exprs = [mask[d] ? :(slice_A[$d]) : :(I[$d]) for d in 1:N]
  :(tuple($(exprs...)))
end


"""
    par_mapslices(f, A::AbstractArray{<:Real,N}, args...; dims=N, kw...)

# Arguments
- `dims`: the dimension apply f

@seealso `mapslices`

# Example
```julia
using Ipaper
using Distributions

A = rand(100, 100, 30, 4)
obj_size(A)

par_mapslices(mean, A)

# @time r = mapslices(slope_mk, A; dims=3);
# @time r_par = par_mapslices(slope_mk, A; dims=3); # 5X faster
```
"""
function par_mapslices(f, A::AbstractArray{<:Real,N}, args...;
  dims=N, parallel=true, progress=true, kw...) where {N}

  idx1 = ntuple(d -> d in dims ? (:) : firstindex(A, d), N)
  Aslice = A[idx1...]
  r1 = f(Aslice, args...; kw...)

  _dims = ntuple(d -> d in dims ? length(r1) : size(A, d), N)
  dim_mask = ntuple(d -> d in dims, N)
  dim_mask_val = Val(dim_mask)

  itershape = ntuple(d -> d in dims ? Base.OneTo(1) : axes(A, d), N)
  indices = CartesianIndices(itershape)
  n = length(indices)

  R = zeros(eltype(r1), _dims)
  slice_A = Slice.(axes(A))
  slice_R = Slice.(axes(R))

  p = Progress(n)

  nt = parallel ? Threads.nthreads() : 1
  actual_nt = min(nt, max(n, 1))
  chunks = r_chunk(n, actual_nt)

  # Per-thread dense buffers: avoid strided SubArray overhead in the inner loop
  buffers = [similar(Aslice) for _ in 1:actual_nt]

  @par parallel for t in 1:actual_nt
    buf = buffers[t]
    @inbounds for i in chunks[t]
      I_tup = Tuple(indices[i])
      idx  = _make_slice_idx(dim_mask_val, slice_A, I_tup)
      ridx = _make_slice_idx(dim_mask_val, slice_R, I_tup)
      copyto!(buf, view(A, idx...))
      r = f(buf, args...; kw...)
      concatenate_setindex!(R, r, ridx...)
      progress && next!(p)
    end
  end
  R
end
