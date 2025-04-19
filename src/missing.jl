# const RealOrMissing = Union{Missing,Real}
# 可以含有missing、也可以不含有
# AbstractMissOrRealArray = AbstractArray{<:Union{T,Missing}} where {T<:Real}
# 必须含有missing
export to_missing, drop_missing, drop_missing!


function getDataType(x)
  T = eltype(x)
  typeof(T) == Union ? x.b : x
end


"""
  to_missing(x::AbstractArray{T}, replacement=0)
  
  to_missing(x::AbstractArray{Union{T,Missing}}, replacement=0)
  
  to_missing!(x::AbstractArray{Union{T,Missing}}, replacement=0)

convert `replacement` to `missing`

$(TYPEDSIGNATURES)

# Usage

$(METHODLIST)
"""
function to_missing(x::AbstractArray{T}, replacement=0) where {T<:Real}
  x2 = Array{Union{Missing,T}}(x) # this is a deepcopy
  to_missing!(x2, replacement)
end

function to_missing(x::AbstractArray{Union{T,Missing}}, replacement=0) where {T<:Real}
  replace(x, T(replacement) => missing)
end

# not for user
function to_missing!(x::AbstractArray{Union{T,Missing}}, replacement=0) where {T<:Real}
  replace!(x, T(replacement) => missing)
end


"""
drop_missing

$(TYPEDSIGNATURES)
"""
function drop_missing(x::AbstractArray{Union{T,Missing}}, replacement=NaN) where {T<:Real}  
  x2 = replace(x, missing => T(replacement))
  Array{T}(x2)
end

drop_missing(x::AbstractArray{T}, replacement=NaN) where {T<:Real} = x

# not for user
function drop_missing!(x::AbstractArray{Union{T,Missing}}, replacement=NaN) where {T<:Real}
  replace!(x, missing => T(replacement))
end

# not for user
drop_missing!(x::AbstractArray{T}, replacement=NaN) where {T<:Real} = x


replace_miss = drop_missing

# function replace_value!(x::AbstractMissOrRealArray{T}, old::O, new::N) where {T<:Real, O<:Real, N<:Real}
#   replace!(x, T(old) => T(new))
# end

# function replace_value(x::AbstractMissOrRealArray{T}, old::Missing, new::N) where {T<:Real, N<:Real}
#   drop_missing!(x, new)
# end

# # unable to replace value
# function replace_value(x::AbstractArray{T}, old::O, new::Missing) where {T<:Real,O<:Real}
#   to_missing(x, old)
# end

# function replace_value!(x::AbstractArray{Union{T,Missing}}, old::O, new::Missing) where {T<:Real, O<:Real}
#   to_missing!(x, old)
# end
