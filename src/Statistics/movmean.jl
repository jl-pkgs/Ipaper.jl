function movmean!(z::AbstractVector{FT}, x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false) where {FT<:Real, T<:Real}
  win_left, win_right = win
  ∑ = ∅ = FT(0)
  ∑w = ∅w = 0

  @inbounds @simd for i ∈ eachindex(x)
    ibeg = max(i - win_left, firstindex(x))
    iend = min(i + win_right, lastindex(x))
    ∑ = ∅
    ∑w = ∅w
    for j = ibeg:iend
      skip = skip_centre && i == j
      xᵢ = x[j]
      notnan = (xᵢ == xᵢ) && !skip
      ∑ += ifelse(notnan, xᵢ, ∅)
      ∑w += ifelse(notnan, 1, 0)
    end
    z[i] = ∑ / ∑w
  end
  z
end


"""
    movmean(x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1); skip_centre=false) where {T<:Real}

Compute the moving mean of the input vector `x` with a specified window size.

# Arguments
- `x::AbstractVector{T}`: Input vector of type `T` where `T` is a subtype of `Real`.
- `win::Tuple{Int,Int}`: A tuple specifying the window size `(win_left, win_right)`. Default is `(1, 1)`.
- `skip_centre::Bool`: If `true`, the center element is skipped in the mean calculation. Default is `false`.

# Returns
- A vector of the same length as `x` containing the moving mean values.

# Example
```julia
x = [1.0, 2.0, 3.0, 4.0, 5.0]
movmean(x, (1, 1))  # returns [1.5, 2.0, 3.0, 4.0, 4.5]
movmean(x, (1, 1); skip_centre=true)  # returns [1.0, 2.0, 3.0, 4.0, 5.0]
```
"""
function movmean(x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1); skip_centre=false) where {T<:Real}
  FT = Base.promote_op(/, T, Int)
  z = similar(x, FT)
  movmean!(z, x, win; skip_centre)
end

# multiple dimension case
"""
  $(TYPEDSIGNATURES)

moving mean average
"""
function movmean(x::AbstractArray{T}, win::Tuple{Int,Int}; skip_centre=false, dims=3) where {T<:Real}
  @assert length(dims) == 1 "The length of `dims` should be 1!"
  FT = Base.promote_op(/, T, Int)
  n = size(x, dims)
  zi = zeros(FT, n)
  mapslices(xi -> movmean!(zi, xi, win; skip_centre), x; dims)
end

function movmean(x::AbstractArray{T}, halfwin::Int=1; skip_centre=false, kw...) where {T<:Real}
  movmean(x, (halfwin, halfwin); skip_centre, kw...)
end



# 4 times slower
function weighted_movmean!(z::AbstractVector, x::AbstractVector, w::AbstractVector,
  halfwin::Integer=2; fun::Function=weighted_mean)

  n = length(x)
  @inbounds for i = 1:n
    i_begin = i <= halfwin ? 1 : i - halfwin
    i_end = i <= n - halfwin ? i + halfwin : n
    xi = view(x, i_begin:i_end)
    wi = view(w, i_begin:i_end)
    z[i] = fun(xi, wi)
  end
  z
end

function weighted_movmean(x::AbstractArray{Tx}, w::AbstractVector{Tw}, halfwin::Integer=2;
  fun=weighted_mean, FT=Float32) where {Tx<:Real,Tw<:Real}
  # if FT === nothing
  #   FT = Tx <: Integer && !(Tw <: Integer) ? Tw : Tx
  # end
  n = length(x)
  z = zeros(FT, n)
  weighted_movmean!(z, x, w, halfwin; fun=fun)
end
