module sf


using Ipaper: file_ext, obj_size

export bbox, in_bbox, bbox_overlap
export bbox2lims, 
  bbox2cellsize,
  bbox2range, bbox2vec,
  bbox2dims, bbox2ndim
export range2bbox
export st_bbox, st_dims, st_cellsize


include("bbox.jl")
include("st_bbox.jl")
include("st_dims.jl")
include("Raster.jl")

end
