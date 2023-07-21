import Dates
import Dates: DateTime, Year, Month, Day, year, month, day, format
# using CFTime

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


export dates_miss, dates_nmiss,
    DateTime, Date, year, month, day, Year, Month, Day, format, 
    make_datetime, make_date, 
    date_year, date_ym
