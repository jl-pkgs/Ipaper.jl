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
  return R
end

function agg(A::AbstractArray{<:Real,3}; fact=2, parallel=true, fun=mean)
  R = A[1:fact:end, 1:fact:end, :] .* 0
  agg!(R, A; fact, parallel, fun)
end


function agg_time(A::AbstractArray{T,3}; fact::Int=2, parallel=true, progress=false, fun=mean) where {T<:Real}
  nlon, nlat, ntime = size(A)
  _ntime = cld(ntime, fact)
  R = A[:, :, 1:fact:end] .* 0

  p = Progress(ntime)
  @inbounds @par parallel for k = 1:_ntime
    progress && next!(p)
    I = (k-1)*fact+1:min(k * fact, ntime)
    for j = 1:nlat, i = 1:nlon
      R[i, j, k] = fun(@view A[i, j, I])
    end
  end
  return R
end


"""
    agg_time(A::AbstractArray{T,3}, by::Vector; parallel=true, progress=false, 
        fun=mean) where {T<:Real}
    agg_time(A::AbstractArray{T,3}; fact::Int=2, parallel=true, progress=false, 
      fun=mean) where {T<:Real}
"""
function agg_time(A::AbstractArray{T,3}, by::Vector; parallel=true, progress=false, fun=mean) where {T<:Real}
  nlon, nlat, ntime = size(A)
  grps = unique_sort(by)
  _ntime = length(grps)
  R = zeros(T, nlon, nlat, _ntime)

  p = Progress(ntime)
  @inbounds @par parallel for k = 1:_ntime
    progress && next!(p)
    I = (grps[k] .== by) |> findall # 必须要有findall

    for j = 1:nlat, i = 1:nlon
      R[i, j, k] = fun(@view A[i, j, I])
    end
  end
  return R
end

function agg_time(A::AbstractVector{T}, by::Vector; fun=mean) where {T<:Real}
  grps = unique_sort(by)
  _ntime = length(grps)
  R = zeros(T, _ntime)

  @inbounds for k = 1:_ntime
    I = (grps[k] .== by) #|> findall # 必须要有findall
    R[k] = fun(@view A[I])
  end
  return R
end

export agg!, agg, agg_time
