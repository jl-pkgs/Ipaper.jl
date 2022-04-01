const DD = DimensionalData
const TYPE_dimname = Union{Symbol,AbstractString}
const dimnames_default = ["x", "y", "z", "t"]

# https://github.com/rafaqz/DimensionalData.jl/issues/370

# function make_dims(vals::Vector, names::Vector{<:TYPE_dimname})
#   (; zip(Symbol.(names), vals)...)
# end

# function make_dims(val, name::TYPE_dimname)
#   make_tuple([val], [name])
# end

# vals = [1:i for i in Size] |> collect
# make_tuple(vals, dimnames[1:n])

function make_dims(array::AbstractArray, dimnames::Vector{<:TYPE_dimname} = dimnames_default)
  n = size(array) |> length
  length(dimnames) < n && error("The length of `names` is short than `dims`")
  Size = size(array)
  dimnames = Symbol.(dimnames)
  
  [Dim{dimnames[i]}(1:Size[i]) for i in 1:length(Size)]
end

function DimensionalData.DimArray(
  array::AbstractArray, dimnames::Vector{<:TYPE_dimname} = dimnames_default; kw...)
  
  dims = make_dims(array, dimnames)
  DimArray(array, Tuple(dims), kw...) # 
end


const TYPE_DIM = Union{AbstractString,Symbol,Integer,Type{<:Dim}}

which_dim(d, dim::AbstractString) = findall(string.(name(d.dims)) .== dim)[1]
which_dim(d, dim::Symbol) = findall(name(d.dims) .== dim)[1]
which_dim(d, dim::Type{<:Dim}) = findall(name(d.dims) .== name(dim))[1]
which_dim(d, dim::Integer) = dim

# not passed test
dimnum2(d, dims::Vector{<:TYPE_DIM}) = begin
  nums = [which_dim(d, dim) for dim in dims]
  tuple(nums...)
end

dimnum2(d, dims::TYPE_DIM) = begin
  dimnum2(d, [dims])
end


export DimArray, which_dim, which_dims, dimnum2
