using Dates
using Printf: @sprintf

# DateType = Union{Date,DateTime,AbstractCFDateTime,Nothing}
_gte(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x >= trs + wl
_gt(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x > trs + wl
_exceed(x::T, trs::T, wl::T=T(0)) where {T<:Real} = x - trs + wl


# format_md(date) = @sprintf("%02d-%02d", month(date), day(date))
format_md(date) = month(date)*100 + day(date)


# function find_adjacent_doy2(doy::Int; doy_max::Int=366, halfwin::Int=7)
#   ind = (-halfwin:halfwin) .+ doy

#   if ind[end] > doy_max
#     [doy-halfwin:doy_max, 1:ind[end]-doy_max]
#   elseif ind[1] < 1
#     [1:ind[end], ind[1]+doy_max:doy_max]
#   else
#     [ind]
#   end
# end

function find_adjacent_doy(doy::Int; doy_max::Int=366, halfwin::Int=7)
  ind = collect(-halfwin:halfwin) .+ doy
  for i = eachindex(ind)
    if ind[i] > doy_max
      ind[i] = ind[i] - doy_max
    end
    if ind[i] <= 0
      ind[i] = ind[i] + doy_max
    end
  end
  ind
end


function filter_mds(mmdd::AbstractVector, doy::Int; doy_max::Integer=366, halfwin::Int=7, use_mov=true)
  !use_mov && (return mmdd .== doy)

  ind = (-halfwin:halfwin) .+ doy
  if ind[end] > doy_max
    # ind1, ind2 = doy-halfwin:doy_max, 1:ind[end]-doy_max
    @.(doy - halfwin <= mmdd <= doy_max || 1 <= mmdd <= ind[end] - doy_max)
  elseif ind[1] < 1
    # ind1, ind2 = 1:ind[end], ind[1]+doy_max:doy_max
    @.(1 <= mmdd <= ind[end] || ind[1] + doy_max <= mmdd <= doy_max)
  else
    @.(ind[1] <= mmdd <= ind[end])
  end
end


export format_md, find_adjacent_doy, filter_mds
