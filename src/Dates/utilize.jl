function datediff(x::T, y::T; unit=Day) where {T<:Union{Date,DateTime}}
  convert(unit, x - y).value
end

# only for daily scale 
function dates_miss(dates)
  date_begin = first(dates)
  date_end = last(dates)
  dates_full = date_begin:Dates.Day(1):date_end
  setdiff(dates_full, dates)
end

# only for daily scale 
function dates_nmiss(dates)
  date_begin = first(dates)
  date_end = last(dates)

  n_full = (date_end - date_begin) / convert(Dates.Millisecond, Dates.Day(1)) + 1 |> Int
  n_full - length(dates) # n_miss
end

make_datetime = DateTime
make_date = DateTime


date_year(dates) = make_date.(year.(dates))
date_ym(dates) = make_date.(year.(dates), month.(dates))

function date_dn(year::Int, dn::Int; delta=8)
  Date(year) + Day((dn - 1) * delta)
end

function date_dn(date; delta=8)
  days = Dates.dayofyear(date)
  dn = cld(days, delta) # int
  date_dn(year(date), dn; delta)
end

"""
    date_doy(str::AbstractString)
    date_doy(year::Int, doy::Int=1)

```julia
date_doy("2000049")
```
"""
function date_doy(year::Int, doy::Int=1)
  Date(year) + Day(doy - 1)
end

function date_doy(str::AbstractString)
  year = parse(Int, str[1:4])
  doy = parse(Int, str[5:7])
  date_doy(year, doy)
end

Dates.year(x::AbstractString) = parse(Int, x[1:4])
Dates.month(x::AbstractString) = parse(Int, x[6:7])
Dates.day(x::AbstractString) = parse(Int, x[9:10])
