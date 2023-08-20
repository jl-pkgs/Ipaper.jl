# https://github.com/MasonProtter/MutableNamedTuples.jl
# Copyright (c) 2021 Mason Protter

struct MutableNamedTuple{N,T<:Tuple{Vararg{Ref}}}
  nt::NamedTuple{N,T}
end

MutableNamedTuple(; kwargs...) = MutableNamedTuple(NamedTuple{keys(kwargs)}(Ref.(values(values(kwargs)))))

function MutableNamedTuple{names}(tuple::Tuple) where {names}
  MutableNamedTuple(NamedTuple{names}(Ref.(tuple)))
end

Base.keys(::MutableNamedTuple{names}) where {names} = names
Base.values(mnt::MutableNamedTuple) = getindex.(values(getfield(mnt, :nt)))
refvalues(mnt::MutableNamedTuple) = values(getfield(mnt, :nt))

Base.NamedTuple(mnt::MutableNamedTuple) = NamedTuple{keys(mnt)}(values(mnt))
Base.Tuple(mnt::MutableNamedTuple) = values(mnt)


function Base.show(io::IO, mnt::MutableNamedTuple{names}) where {names}
  print(io, "MutableNamedTuple", NamedTuple(mnt))
end

Base.getproperty(mnt::MutableNamedTuple, s::Symbol) = getfield(getfield(mnt, :nt), s)[]

function Base.setproperty!(mnt::MutableNamedTuple, s::Symbol, x)
  nt = getfield(mnt, :nt)
  getfield(nt, s)[] = x
end
Base.propertynames(::MutableNamedTuple{T,R}) where {T,R} = T

Base.length(mnt::MutableNamedTuple) = length(getfield(mnt, :nt))
Base.iterate(mnt::MutableNamedTuple, iter=1) = iterate(NamedTuple(mnt), iter)
Base.firstindex(mnt::MutableNamedTuple) = 1
Base.lastindex(mnt::MutableNamedTuple) = lastindex(NamedTuple(mnt))
Base.getindex(mnt::MutableNamedTuple, i::Int) = getfield(NamedTuple(mnt), i)
Base.getindex(mnt::MutableNamedTuple, i::Symbol) = getfield(NamedTuple(mnt), i)
function Base.indexed_iterate(mnt::MutableNamedTuple, i::Int, state=1)
  Base.indexed_iterate(NamedTuple(mnt), i, state)
end


# list(keys::Vector{Symbol}, values) = (; zip(keys, values)...)
"""
    list(keys::Vector{Symbol}, values)
    list(keys::Vector{<:AbstractString}, values)
    
# Examples
```julia
list([:dw, :betaw, :swmax, :a, :c, :kh, :uh]
```
"""
list(; kw...) = MutableNamedTuple(; kw...)

list(keys::Vector{Symbol}, values) = MutableNamedTuple(; zip(keys, values)...)

list(keys::Vector{<:AbstractString}, values) = list(Symbol.(keys), values)

function list(keys::Vector{Symbol})
  values = zeros(length(keys))
  list(Symbol.(keys), values)
end

list(keys::Vector{<:AbstractString}) = list(Symbol.(keys))

to_list = list;

Base.names(x::MutableNamedTuple) = keys(x) |> collect

# function Base.values(x::MutableNamedTuple)
#   @show "hello"
#   getindex.(values(getfield(x, :nt))) |> collect
#   # values(x) |> collect
# end

function append(x::MutableNamedTuple, y::MutableNamedTuple)
  list([keys(x)..., keys(y)...],
    [values(x)..., values(y)...],)
end

function Base.:(==)(x::MutableNamedTuple, y::MutableNamedTuple)
  if length(x) != length(y)
    return false
  end
  keys(x) == keys(y) && values(x) == values(y)
end


export list, append
export MutableNamedTuple
