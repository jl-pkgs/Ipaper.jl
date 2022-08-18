using Base: Slice, _unsafe_getindex!


"""
# Arguments
- `f!`: function in the form of `f!(r1, Aslice, args...; kw...)`

"""
function mapslices!(f!::Function, r1, A::AbstractArray, args...; dims, kw...)
    isempty(dims) && return map(f!, A)

    for d in dims
        d isa Integer || throw(ArgumentError("mapslices: dimension must be an integer, got $d"))
        d >= 1 || throw(ArgumentError("mapslices: dimension must be ≥ 1, got $d"))
        # Indexing a matrix M[:,1,:] produces a 1-column matrix, but dims=(1,3) here
        # would otherwise ignore 3, and slice M[:,i]. Previously this gave error:
        # BoundsError: attempt to access 2-element Vector{Any} at index [3]
        d > ndims(A) && throw(ArgumentError("mapslices does not accept dimensions > ndims(A) = $(ndims(A)), got $d"))
    end
    dim_mask = ntuple(d -> d in dims, ndims(A))

    # Apply the function to the first slice in order to determine the next steps
    idx1 = ntuple(d -> d in dims ? (:) : firstindex(A, d), ndims(A))
    Aslice = A[idx1...]
    f!(r1, Aslice, args...; kw...)
    res1 = r1
    # Determine result size and allocate. We always pad ndims(res1) out to length(dims):
    din = Ref(0)
    Rsize = ntuple(ndims(A)) do d
        if d in dims
            axes(res1, din[] += 1)
        else
            axes(A, d)
        end
    end
    R = similar(res1, Rsize)

    itershape = ntuple(d -> d in dims ? Base.OneTo(1) : axes(A, d), ndims(A))
    indices = Iterators.drop(CartesianIndices(itershape), 1)

    # That skips the first element, which we already have:
    ridx = ntuple(d -> d in dims ? Slice(axes(R, d)) : firstindex(A, d), ndims(A))
    concatenate_setindex!(R, res1, ridx...)

    # @show idx1 ridx Rsize Aslice indices
    # @show length(indices) #indices[1]
    # @show itershape

    _inner_mapslices!(R, indices, f!, A, dim_mask, Aslice, res1, args...; kw...)
    return R
end

@noinline function _inner_mapslices!(R, indices, f!, A, dim_mask, Aslice, r, 
    args...; kw...)

    for I in indices
        idx = ifelse.(dim_mask, Slice.(axes(A)), Tuple(I))
        _unsafe_getindex!(Aslice, A, idx...)


        f!(r, Aslice, args...; kw...)
        
        ridx = ifelse.(dim_mask, Slice.(axes(R)), Tuple(I))
        R[ridx...] = r
    end
end

concatenate_setindex!(R, v, I...) = (R[I...] .= (v,); R)
concatenate_setindex!(R, X::AbstractArray, I...) = (R[I...] = X)
