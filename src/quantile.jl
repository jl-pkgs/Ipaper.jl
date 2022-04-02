import Statistics
import Statistics: require_one_based_indexing
# quantile, quantile!, _quantile,

# const q_missing = missing;
const q_missing = NaN; #-9999.0;

function quantile!(q::AbstractArray, v::AbstractVector, p::AbstractArray;
  sorted::Bool=false, alpha::Real=1.0, beta::Real=alpha)
  require_one_based_indexing(q, v, p)
  if size(p) != size(q)
    throw(DimensionMismatch("size of p, $(size(p)), must equal size of q, $(size(q))"))
  end
  isempty(q) && return q

  minp, maxp = extrema(p)
  _quantilesort!(v, sorted, minp, maxp)

  for (i, j) in zip(eachindex(p), eachindex(q))
    @inbounds q[j] = _quantile(v, p[i], alpha=alpha, beta=beta)
  end
  return q
end

function quantile!(v::AbstractVector, p::Union{AbstractArray,Tuple{Vararg{Real}}};
  sorted::Bool=false, alpha::Real=1.0, beta::Real=alpha)
  if !isempty(p)
    minp, maxp = extrema(p)
    _quantilesort!(v, sorted, minp, maxp)
  end
  return map(x -> _quantile(v, x, alpha=alpha, beta=beta), p)
end

quantile!(v::AbstractVector, p::Real; sorted::Bool=false, alpha::Real=1.0, beta::Real=alpha) =
  _quantile(_quantilesort!(v, sorted, p, p), p, alpha=alpha, beta=beta)

# Function to perform partial sort of v for quantiles in given range
function _quantilesort!(v::AbstractArray, sorted::Bool, minp::Real, maxp::Real)
  isempty(v) && return #throw(ArgumentError("empty data vector"))
  require_one_based_indexing(v)

  if !sorted
    lv = length(v)
    lo = floor(Int, minp * (lv))
    hi = ceil(Int, 1 + maxp * (lv))

    # only need to perform partial sort
    sort!(v, 1, lv, Base.Sort.PartialQuickSort(lo:hi), Base.Sort.Forward)
  end
  if (sorted && (ismissing(v[end]) || (v[end] isa Number && isnan(v[end])))) ||
     any(x -> ismissing(x) || (x isa Number && isnan(x)), v)
    throw(ArgumentError("quantiles are undefined in presence of NaNs or missing values"))
  end
  return v
end

# Core quantile lookup function: assumes `v` sorted
@inline function _quantile(v::AbstractVector, p::Real; alpha::Real=1.0, beta::Real=alpha)
  0 <= p <= 1 || throw(ArgumentError("input probability out of [0,1] range"))
  0 <= alpha <= 1 || throw(ArgumentError("alpha parameter out of [0,1] range"))
  0 <= beta <= 1 || throw(ArgumentError("beta parameter out of [0,1] range"))
  require_one_based_indexing(v)

  n = length(v)

  # @assert n > 0 # this case should never happen here
  n == 0 && return q_missing

  m = alpha + p * (one(alpha) - alpha - beta)
  aleph = n * p + oftype(p, m)
  j = clamp(trunc(Int, aleph), 1, n - 1)
  γ = clamp(aleph - j, 0, 1)

  if n == 1
    a = v[1]
    b = v[1]
  else
    a = v[j]
    b = v[j+1]
  end

  if isfinite(a) && isfinite(b)
    return a + γ * (b - a)
  else
    return (1 - γ) * a + γ * b
  end
end

_quantile(v::Nothing, p::Real; alpha::Real=1.0, beta::Real=alpha) = q_missing;
_quantile(v::Vector{Union{}}, p::Real; alpha::Real=1.0, beta::Real=alpha) = q_missing;

quantile!(v::Vector{Union{}}, p::Float64; kw...) = q_missing;


quantile2(itr, p; sorted::Bool=false, alpha::Real=1.0, beta::Real=alpha) =
  quantile!(collect(itr), p, sorted=sorted, alpha=alpha, beta=beta)

quantile2(v::AbstractVector, p; sorted::Bool=false, alpha::Real=1.0, beta::Real=alpha) =
  quantile!(sorted ? v : Base.copymutable(v), p; sorted=sorted, alpha=alpha, beta=beta)

# fix quantile missing
quantile2(x::Vector{Missing}, p; kw...) = repeat([q_missing], length(p))


export quantile2
