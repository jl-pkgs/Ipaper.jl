## MutableNamedTuples
# using MutableNamedTuples
# using Ipaper
import MutableNamedTuples: MutableNamedTuple

const MNT = MutableNamedTuple

# list(keys::Vector{Symbol}, values) = (; zip(keys, values)...)
"""
    list(keys::Vector{Symbol}, values)
    list(keys::Vector{<:AbstractString}, values)
    
# Examples
```julia
list([:dw, :betaw, :swmax, :a, :c, :kh, :uh]
```
"""
list(; kw...) = MNT(; kw...)

list(keys::Vector{Symbol}, values) = MNT(; zip(keys, values)...)

list(keys::Vector{<:AbstractString}, values) = list(Symbol.(keys), values)

function list(keys::Vector{Symbol})
  values = zeros(length(keys))
  list(Symbol.(keys), values)
end

list(keys::Vector{<:AbstractString}) = list(Symbol.(keys))

to_list = list;

Base.names(x::MNT) = keys(x) |> collect

# function Base.values(x::MNT)
#   @show "hello"
#   getindex.(values(getfield(x, :nt))) |> collect
#   # values(x) |> collect
# end


function add(x::MutableNamedTuple, y::MutableNamedTuple)
  list([keys(x)..., keys(y)...],
    [values(x)..., values(y)...],)
end

function Base.:(==)(x::MNT, y::MNT)
  if length(x) != length(y)
    return false
  end
  keys(x) == keys(y) && values(x) == values(y)
end

export list, add
