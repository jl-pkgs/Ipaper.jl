function interval_intersect(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:Real}
  left = max(x[1], y[1]) # intersect
  right = min(x[2], y[2])

  if left <= right
    return right - left
  else
    return 0
  end
end

function interval_intersect(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:Union{Date,DateTime}}
  left = max(x[1], y[1]) # intersect
  right = min(x[2], y[2])

  if left <= right
    return convert(Dates.Day, right - left)
  else
    return Day(0)
  end
end
