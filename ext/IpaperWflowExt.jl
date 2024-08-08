export IpaperWflowExt
module IpaperWflowExt


import Ipaper: flowdir_drop_missing!
import Wflow
import Wflow.Graphs: outneighbors, topological_sort_by_dfs
import Wflow: stream_order, subbasins, fillnodata_upstream
stream_link = subbasins
# stream_link(g, streamorder, toposort, min_sto)


function reverse_index(z::AbstractVector{T}, inds, inds_rev; mv::T) where {T}
  R = zeros(T, size(inds_rev)) .+ mv
  @inbounds for (i, I) in enumerate(inds)
    R[I] = z[i]
  end
  R
end

"""
- `min_sto`: 过小的sto不认为是stream link
"""
function SubBasins(A_fdir::AbstractMatrix; min_sto::Int=4)
  ldd_mv = UInt8(99)
  # _drop_missing(A) = drop_missing(A, ldd_mv)
  flowdir_drop_missing!(A_fdir)
  # ldd_2d = Array(nc["wflow_ldd"])[:, end:-1:1] |> _drop_missing

  inds, inds_rev = Wflow.active_indices(A_fdir, ldd_mv)
  ldd = A_fdir[inds]

  g = Wflow.flowgraph(ldd, inds, Wflow.pcr_dir)
  toposort = topological_sort_by_dfs(g)

  strord = stream_order(g, toposort)
  strord_2d = reverse_index(strord, inds, inds_rev; mv=-1)

  links = stream_link(g, strord, toposort, min_sto)
  links_2d = reverse_index(links, inds, inds_rev; mv=0)

  basinId_fill = fillnodata_upstream(g, toposort, links, 0)
  basinId_2d = reverse_index(basinId_fill, inds, inds_rev; mv=0)
  strord_2d, links_2d, basinId_2d
end


export SubBasins

end
