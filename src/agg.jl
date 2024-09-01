"""
    agg!(R::AbstractArray{FT,3}, A::AbstractArray{<:Real,3}; 
        fact=2, parallel=true, fun=mean)
    agg(A::AbstractArray{<:Real,3}; fact=2, parallel=true, fun=mean)

Aggregate a 3D array `A` by a factor of `fact` in time dimension (third dim)
using the function `fun`.
"""
function agg!(R::AbstractArray{FT,3}, A::AbstractArray{<:Real,3}; 
  fact=2, parallel=true, progress=true, fun=mean) where {FT<:Real}
  
  nlon, nlat, ntime = size(A)
  _nlon = cld(nlon, fact)
  _nlat = cld(nlat, fact)

  p = Progress(_nlat)
  @inbounds @par parallel for j = 1:_nlat
    for i = 1:_nlon
      I = (i-1)*fact+1:min(i * fact, nlon)
      J = (j-1)*fact+1:min(j * fact, nlat)

      for k = 1:ntime
        R[i, j, k] = fun(@view A[I, J, k])
      end
    end
    progress && next!(p)
  end
  R
end

function agg(A::AbstractArray{<:Real,3}; fact=2, parallel=true, fun=mean)
  R = A[1:fact:end, 1:fact:end, :] .* 0
  agg!(R, A; fact, parallel, fun)
end


export agg!, agg
