# """
# $(TYPEDSIGNATURES)
# """
# function cal_climatology_base3!(Q::AbstractArray{T,3}, A::AbstractArray{T,3}, mmdd;
#   use_mov=true, halfwin::Int=7,
#   parallel::Bool=true, fun=nanmean,
#   ignored...) where {T<:Real}

#   doy_max = maximum(mmdd)

#   nlon, nlat, _ = size(A)
#   @inbounds @par parallel for doy = 1:doy_max
#     ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)
#     for i = 1:nlon, j = 1:nlat
#       x = @view A[i, j, ind]
#       Q[i, j, doy] = fun(x)
#     end
#   end
#   Q
# end


function cal_climatology_base!(Q::AbstractArray{T,N}, A::AbstractArray{T,N}, mmdd;
  use_mov=true, halfwin::Int=7,
  dims=N,
  parallel::Bool=true, fun=nanmean,
  ignored...) where {T<:Real,N}

  doy_max = maximum(mmdd)

  @par parallel for doy = 1:doy_max
    ind = filter_mds(mmdd, doy; doy_max, halfwin, use_mov)
  
    _data = selectdim(A, dims, ind)
    _Q = selectdim(Q, dims, doy)
    _Q .= mapslices(fun, _data; dims)
  end
  Q
end


"""
$(TYPEDSIGNATURES)

Calculate the climatology of a dataset `A` based on the `dates`.

The climatology is the long-term average of a variable over a specific period of time.
This function calculates the climatology of the input dataset `A` based on the dates `dates`.
The calculation is performed by applying a function `fun!` to a moving window of the data.

Arguments:
- `A            : :AbstractArray{T}`: the input dataset, where `T` is a subtype of `Real`.
- `dates`       : the dates associated with the input dataset, as a vector of `Date` objects.
- `fun!`        : the function to apply to the moving window of the data. It should take an input array and return a scalar.
- `use_quantile`: default false, a boolean indicating whether to use a quantile-based filter to remove outliers.
- `p1`, `p2`    : the references period

Returns:
- a matrix of the same size as `A`, containing the climatology values.

Example:
```julia
using Dates
A = rand(365, 10)  # simulate a year of daily data for 10 variables
dates = Date(2022, 1, 1):Day(1):Date(2022, 12, 31)
clim = cal_climatology_base(A, dates; fun! = mean)
```
"""
function cal_climatology_base(A::AbstractArray{T}, dates;
  (fun!)=cal_climatology_base!, kw...) where {T<:Real}

  cal_mTRS_base(A, dates; use_quantile=false, (fun!), kw...)
end


"""  
$(TYPEDSIGNATURES)
"""
function cal_climatology_full(A::AbstractArray{T}, dates;
  (fun!)=cal_climatology_base!, kw...) where {T<:Real}

  cal_mTRS_full(A, dates; use_quantile=false, (fun!), kw...)
end
