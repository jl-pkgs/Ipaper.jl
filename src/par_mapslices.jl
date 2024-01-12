export par_mapslices, par_map


import Base.Threads
import Base: Slice, concatenate_setindex!, _unsafe_getindex!

"""
    par_map(f, A, args...; kw...)

# Examples
```julia
function f(x)
  sleep(0.1)
  x
end

# get_clusters()
@time par_map(f, 1:10)
@time map(f, 1:10)
```
"""
function par_map(f, A, args...; parallel=true, progress=true, kw...)
  n = prod(size(A))
  p = Progress(n)

  res = Vector{Any}(undef, size(A))
  @par parallel for i in eachindex(A)
    progress && next!(p)
    
    x = A[i]
    r = f(x, args...; kw...)
    res[i] = r
  end
  res
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

A = rand(10, 10, 30, 4)
par_mapslices(mean, A)

# @time r1 = par_mapslices(slope_mk, A; dims=3); # 5X faster
```
"""
function par_mapslices(f, A::AbstractArray{<:Real,N}, args...;
  dims=N, parallel=true, progress=true, kw...) where {N}

  idx1 = ntuple(d -> d in dims ? (:) : firstindex(A, d), ndims(A))
  Aslice = A[idx1...]
  r1 = f(Aslice)

  _dims = size(A) |> collect
  _dims[dims] = length(r1)

  dim_mask = ntuple(d -> d in dims, ndims(A))

  itershape = ntuple(d -> d in dims ? Base.OneTo(1) : axes(A, d), ndims(A))
  indices = CartesianIndices(itershape)
  n = prod(size(indices))
  p = Progress(n)

  R = zeros(eltype(r1), _dims...)
  slice_A = Slice.(axes(A))
  slice_R = Slice.(axes(R))

  @inbounds @par parallel for I in indices
    progress && next!(p)

    idx = ifelse.(dim_mask, slice_A, Tuple(I))
    ridx = ifelse.(dim_mask, slice_R, Tuple(I))

    # _unsafe_getindex!(Aslice, A, idx...)
    Aslice = @view A[idx...] # consume large memory
    r = f(Aslice, args...; kw...)
    concatenate_setindex!(R, r, ridx...)
  end
  R #|> squeeze
end

# if option == 1
#   # 方案1：划分成块
#   inds = collect(indices)[:]
#   nworker = get_clusters()
#   i_chunks = r_chunk(inds, nworker)

#   # kws = [deepcopy(kw) for _ in 1:nworker]  
#   slices = [zeros(size(Aslice)) for _ in 1:nworker]

#   @par parallel for t = 1:nworker
#     x = slices[t]

#     @inbounds for I in i_chunks[t]
#       idx = ifelse.(dim_mask, slice_A, Tuple(I))
#       ridx = ifelse.(dim_mask, slice_R, Tuple(I))

#       _unsafe_getindex!(x, A, idx...) # this not work
#       # Aslice = @view A[idx...] # consume large memory
#       # R[ridx...] .= r
#       r = f(Aslice, args...; kw...)
#       concatenate_setindex!(R, r, ridx...)
#     end
#   end
# elseif option == 2
# end
