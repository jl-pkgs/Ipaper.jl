add_d8(date::T) where {T<:Union{Date,DateTime}} =
  min(date + Day(7), T(year(date), 12, 31))

"""
    weight_d8mon(dates_beg::Vector{T}, date::T) where {T<:Union{Date,DateTime}}
    weight_d8mon(dates_beg::Vector{T}, dates_end::Vector{T}, date::T) where {T<:Union{Date,DateTime}}

convert MODIS 8-day to monthly
"""
function weight_d8mon(dates_beg::Vector{T}, date::T) where {T<:Union{Date,DateTime}}
  dates_end = add_d8.(dates_beg)
  weight_d8mon(dates_beg, dates_end, date)
end

function weight_d8mon(dates_beg::Vector{T}, dates_end::Vector{T}, date::T) where {T<:Union{Date,DateTime}}
  date_beg = date
  date_end = T(year(date_beg), month(date_beg), daysinmonth(date_beg))
  interval = (date_beg, date_end)

  inds = findall(@.(
    date_beg <= dates_beg <= date_end ||
    date_beg <= dates_end <= date_end))
  days_full = datediff.(dates_end[inds], dates_beg[inds]) .+ 1

  days = map(i -> begin
      date_beg, date_end = dates_beg[i], dates_end[i]
      int2 = date_beg, date_end
      interval_intersect(interval, int2) + Day(1) |> x -> x.value
    end, inds)
  (; date_beg=dates_beg[inds], date_end=dates_end[inds], index=inds,
    days, days_full, w=days ./ days_full)
end
