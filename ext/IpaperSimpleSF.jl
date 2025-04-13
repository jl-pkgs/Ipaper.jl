export IpaperSimpleSF
module IpaperSimpleSF


using Shapefile, DataFrames
import Shapefile: getshp, getdbf, GI, GFT

import Ipaper.sf: read_sf, write_sf

Base.@kwdef struct SimpleSF
  # geometry # Vector{Shapefile.Shape}
  data::DataFrame     # DataFrame(Table)
  crs::Union{GFT.ESRIWellKnownText,Nothing} = Nothing
end

function SimpleSF(x::Shapefile.Table)
  data = DataFrame(x)
  crs = GI.crs(x)
  SimpleSF(data, crs)
end

funcs = [:size, :first, :last, :names]
for f in funcs
  @eval Base.$f(x::SimpleSF, args...) = $f(x.data, args...)
end

funcs = [:getindex]
for f in funcs
  @eval Base.$f(x::SimpleSF, args...) = begin
    data = $f(x.data, args...)
    SimpleSF(data, x.crs)
  end
end


function write_sf(f::AbstractString, x::SimpleSF, args...; force=true, kw...)
  Shapefile.write(f, x.data, args...; force, kw...)

  f_prj = replace(f, r".shp$" => ".prj")
  if x.crs === nothing # no crs
    isfile(f_prj) && rm(f_prj)
    return nothing
  end

  open(f_prj, "w") do fid
    write(fid, x.crs.val)
    write(fid, "\n")
  end
  nothing
end

read_sf(f) = Shapefile.Table(f) |> SimpleSF


end
