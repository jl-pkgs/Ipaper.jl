## 计算anomaly的3种方法，考虑每年的升温幅度

# This function need to revise to work for CMIP6 data
# some CMIP6 model not use 366 calendar |> "solved"
DateType = Union{Date,DateTime,AbstractCFDateTime,Nothing}
DataType = Union{Missing,<:Real}

function cal_anomaly(
  arr::AbstractArray{T,3},
  TRS::AbstractArray{T,3},
  dates;
  # parallel::Bool=false, ΔTRS=nothing,
  fun, verbose=false
) where {T<:Real}
  # res = zeros(Bool, size(arr))
  # res = BitArray(undef, size(arr))
  mmdd = Dates.format.(dates, "mm-dd")
  mds = mmdd |> unique |> sort
  # doy_max = length(mds)
  
  idxs = indexin(mmdd, mds)
  fun.(arr, TRS[:, :, idxs])
  
  ## 如果是逐年的需要进行转换
  
end

_gte(x::T, y::T) where {T<:Real} = x >= y
_gt(x::T, y::T) where {T<:Real} = x > y
_exceed(x::T, y::T) where {T<:Real} = x - y

# export operator, gte, gt
