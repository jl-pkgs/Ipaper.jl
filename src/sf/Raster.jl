abstract type AbstractSpatRaster{T,N} end

Base.@kwdef mutable struct SpatRaster{T,N} <: AbstractSpatRaster{T,N}
  A::AbstractArray{T,N}
  b::bbox = bbox(-180.0, -90.0, 180.0, 90.0)
  cellsize::NTuple{2,Real}
  lon::AbstractVector{<:Real}
  lat::AbstractVector{<:Real}
  time::Union{AbstractVector,Nothing} = nothing
  name::String = "Raster"
end

"""
    SpatRaster(A, b::bbox; reverse_lat=true, kw...)

- `kw`: other parameters: `time`, `name`
"""
function SpatRaster(A::AbstractArray{T,N}, b::bbox; reverse_lat=true, time=nothing, name="Raster") where {T,N}
  if N == 3 && size(A, 3) == 1
    A = A[:, :, 1]
  end
  cellsize = bbox2cellsize(b, size(A))
  lon, lat = bbox2dims(b; cellsize, reverse_lat)
  SpatRaster(; A, b, cellsize, lon, lat, time, name)
end

function SpatRaster(r::SpatRaster, A::AbstractArray)
  SpatRaster(A, r.b, r.cellsize, r.lon, r.lat, r.time, r.name) # rebuild
end

Base.parent(ga::AbstractSpatRaster) = ga.A
Base.iterate(ga::AbstractSpatRaster) = iterate(ga.A)
Base.length(ga::AbstractSpatRaster) = length(ga.A)
Base.size(ga::AbstractSpatRaster) = size(ga.A)
Base.eltype(::Type{AbstractSpatRaster{T}}) where {T} = T
Base.map(f, ga::AbstractSpatRaster) = SpatRaster(ga, map(f, ga.A))

# !note about NaN values
Base_ops = ((:Base, :+), (:Base, :-), (:Base, :*), (:Base, :/),
  (:Base, :>), (:Base, :<), (:Base, :>=), (:Base, :<=),
  (:Base, :!=),
  (:Base, :&), (:Base, :|))

for (m, f) in Base_ops
  # _f = Symbol(m, ".:", f)
  @eval begin
    $m.$f(a::AbstractSpatRaster, b::AbstractSpatRaster) = begin
      size(a) != size(b) || throw(DimensionMismatch("size mismatch"))
      SpatRaster(a, $m.$f.(a.A, b.A))
    end

    $m.$f(a::AbstractSpatRaster, b::Real) = SpatRaster(a, $m.$f.(a.A, b))
    $m.$f(a::Real, b::AbstractSpatRaster) = SpatRaster(a, $m.$f.(a, b.A))
  end
end


function Base.show(io::IO, x::SpatRaster)
  T = eltype(x.A)
  printstyled(io, "SpatRaster{$T}: ", color=:blue)
  printstyled(io, "$(x.name)\n", color=:green, underline=true)

  print(io, "  A        : ")
  obj_size(x.A)

  println(io, "  b        : $(x.b)")
  println(io, "  cellsize : $(x.cellsize)")
  println(io, "  lon, lat : $(x.lon), $(x.lat)")
  print(io, "  time     : $(x.time)")
  nothing
end

rast = SpatRaster

export AbstractSpatRaster, SpatRaster, rast
