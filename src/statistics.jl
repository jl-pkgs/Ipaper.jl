import Statistics
import Statistics: quantile, quantile!, _quantile, require_one_based_indexing

function Quantile(array::AbstractArray{<:Real}, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  mapslices(x -> quantile(x, probs), array, dims = dims)
end

function Quantile(array::AbstractNanArray, probs=[0, 0.25, 0.5, 0.75, 1]; dims=1)
  mapslices(x -> begin
    ans = quantile(skipmissing(x), probs)
  end, array, dims=dims)
end

# `dims`: symbol
"""
  Quantile(array::AbstractArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  
# Examples
```julia
arr = rand(200, 200, 365);
d = DimArray(arr, ["lon", "lat", "time"]);
probs = [0.5, 0.9];
Quantile(d, probs; dims = :time)
```
"""
function Quantile(da::AbstractDimArray, probs = [0, 0.25, 0.5, 0.75, 1]; dims = 1)
  # dims = dimnum2(array, dims)
  if eltype(dims) <: Integer; dims = name(da.dims)[dims]; end
  if dims isa String; dims = Symbol(dims); end

  bands = collect(name(da.dims))
  r = mapslices(x -> quantile(x, probs), da, dims = dims)
  r = DimArray(r.data, bands) # dimension error, rebuild it
  set(r, dims => :prob)
end


# const Q_missing = missing;
const Q_missing = -9999.0;

## fix quantile missing
Statistics.quantile!(v::Vector{Union{}}, p::Float64; kw...) = Q_missing;
Statistics.quantile(x::Vector{Missing}, p; kw...) = repeat([Q_missing], length(p))

# function Statistics._quantilesort!(v::Vector{Union{}}, sorted::Bool, minp::Real, maxp::Real) 
#   # isempty(v) && return([])
#   return v;
#   # Vector{Union{}}[]
# end

function Statistics._quantilesort!(v::AbstractArray, sorted::Bool, minp::Real, maxp::Real)
    isempty(v) && return #throw(ArgumentError("empty data vector"))
    require_one_based_indexing(v)

    if !sorted
        lv = length(v)
        lo = floor(Int,minp*(lv))
        hi = ceil(Int,1+maxp*(lv))

        # only need to perform partial sort
        sort!(v, 1, lv, Base.Sort.PartialQuickSort(lo:hi), Base.Sort.Forward)
    end
    if (sorted && (ismissing(v[end]) || (v[end] isa Number && isnan(v[end])))) ||
        any(x -> ismissing(x) || (x isa Number && isnan(x)), v)
        throw(ArgumentError("quantiles are undefined in presence of NaNs or missing values"))
    end
    return v
end


Statistics._quantile(v::Nothing, p::Real; alpha::Real=1.0, beta::Real=alpha) = Q_missing;
Statistics._quantile(v::Vector{Union{}}, p::Real; alpha::Real=1.0, beta::Real=alpha) = Q_missing;

function Statistics._quantile(v::AbstractVector, p::Real; alpha::Real=1.0, beta::Real=alpha)
    0 <= p <= 1 || throw(ArgumentError("input probability out of [0,1] range"))
    0 <= alpha <= 1 || throw(ArgumentError("alpha parameter out of [0,1] range"))
    0 <= beta <= 1 || throw(ArgumentError("beta parameter out of [0,1] range"))
    require_one_based_indexing(v)

    n = length(v)
    if n == 0; return Q_missing; end
    # @assert n > 0 # this case should never happen here
    
    m = alpha + p * (one(alpha) - alpha - beta)
    aleph = n*p + oftype(p, m)
    j = clamp(trunc(Int, aleph), 1, n-1)
    γ = clamp(aleph - j, 0, 1)

    if n == 1
        a = v[1]
        b = v[1]
    else
        a = v[j]
        b = v[j + 1]
    end
    
    if isfinite(a) && isfinite(b)
        return a + γ*(b-a)
    else
        return (1-γ)*a + γ*b
    end
end


# # Function to perform partial sort of v for quantiles in given range
# function Statistics._quantilesort!(v::AbstractArray, sorted::Bool, minp::Real, maxp::Real)
#     isempty(v) && return([]) #throw(ArgumentError("empty data vector"))
#     Statistics.require_one_based_indexing(v)

#     if !sorted
#         lv = length(v)
#         lo = floor(Int,minp*(lv))
#         hi = ceil(Int,1+maxp*(lv))

#         # only need to perform partial sort
#         sort!(v, 1, lv, Base.Sort.PartialQuickSort(lo:hi), Base.Sort.Forward)
#     end
#     if (sorted && (ismissing(v[end]) || (v[end] isa Number && isnan(v[end])))) ||
#         any(x -> ismissing(x) || (x isa Number && isnan(x)), v)
#         throw(ArgumentError("quantiles are undefined in presence of NaNs or missing values"))
#     end
#     return v
# end

export quantile, Quantile
