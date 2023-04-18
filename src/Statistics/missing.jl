# const RealOrMissing = Union{Missing,Real}
"""
  AbstractNaArray = AbstractArray{<:Union{T, Missing}} where T <: Real
  AbstractNanArray = AbstractArray{Union{T, Missing}} where T <: Real

- `AbstractNanArray`: must have missing value
- `AbstractNaArray` : may have missing value

# Examples
```
f(x::AbstractNanArray) = x
# f([1, 2]) # not work
f([1, 2, missing])
f([missing])

f2(x::AbstractNaArray) = x	
f2([1, 2])
f2([1, 2, missing])
f2([missing])
```
"""
# 可以含有missing、也可以不含有
AbstractNaArray = AbstractArray{<:Union{T,Missing}} where {T<:Real}
# 必须含有missing
AbstractNanArray = AbstractArray{Union{T,Missing}} where {T<:Real}


function getDataType(x)
  T = eltype(x)
  typeof(T) == Union ? x.b : x
end


"""
convert `AbstractArray` to `AbstractNanArray`

$(TYPEDSIGNATURES)

"""
to_missing(x::AbstractNanArray) = x


function to_missing(x::AbstractArray{<:Real}, replacement=0)
  # Cannot `convert` an object of type Missing to an object of type Float64
  # 必须先定义一个新的变量
  x2 = zeros(Union{eltype(x),Missing}, size(x)...)
  x2 .= x
  for i = eachindex(x2)
    if x[i] == replacement
      x2[i] = missing
    end
  end
  x2
end

function replace_miss!(x, replacement=NaN)
  T = getDataType(x)
  replace!(x, missing => T(replacement))
end

function replace_miss(x, replacement=NaN)
  T = getDataType(x)
  replace(x, missing => T(replacement))
end

function replace_value!(x::AbstractNaArray, org, new)
  for i in eachindex(x)
    if !ismissing(x[i]) && x[i] == org
      x[i] = new
    end
  end
  x
end

"""
  to_missing(x::AbstractNanArray)
  to_missing(x::AbstractArray{<:Real}, replacement = 0) 

  drop_missing(x::AbstractArray{<:Real}, replacement = 0)
  drop_missing(x::AbstractNanArray, replacement=0)
"""
drop_missing(x::AbstractArray{<:Real}, replacement=0) = x;

function drop_missing(x::AbstractNanArray, replacement=0)
  x2 = ones(eltype(x).b, size(x)...) .* replacement
  for i = eachindex(x)
    if !ismissing(x[i])
      x2[i] = x[i]
    end
  end
  x2
end

## for `AbstractNaArray`: should use `===` to compare
# Base.:-, Base.isequal
function Base.isequal(a::AbstractNaArray, b::AbstractNaArray)
  size(a) != size(b) && return (false)
  for i = eachindex(a)
    if (a[i] !== b[i])
      return (false)
    end
  end
  return (true)
end


export AbstractNaArray, AbstractNanArray,
  isequal,
  getDataType,
  replace_value!,
  replace_miss, replace_miss!, 
  drop_missing, to_missing;
