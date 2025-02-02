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
function movmean(x::AbstractArray{T}, win::Tuple{Int,Int}; skip_centre=false, dims=3) where {T<:Real}
  @assert length(dims) == 1 "The length of `dims` should be 1!"
  FT = Base.promote_op(/, T, Int)
  n = size(x, dims)
  zi = zeros(FT, n)
  mapslices(xi -> movmean!(zi, xi, win; skip_centre), x; dims)
end

function movmean(x::AbstractArray{T}, halfwin::Int; skip_centre=false, kw...) where {T<:Real}
  movmean(x, (halfwin, halfwin); skip_centre, kw...)
end


function movmean!(z::AbstractVector{FT}, x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false) where {FT<:Real,T<:Real}
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
    weighted_movmean!(z::AbstractVector{FT}, x::AbstractVector{Tx}, w::AbstractVector{Tw}, 
        win::Tuple{Int,Int}=(1, 1); skip_centre=false) where {FT<:Real,Tx<:Real,Tw<:Real}

Calculate the weighted moving mean of the input vector `x` using the window
defined by `win` and the specified `weights`, and store the result in the
preallocated output vector `z`.

# Arguments
- `z`: Preallocated output vector to store the computed weighted moving mean values.
- `x`: Input vector of real numbers.
- `w`: Vector of weights to be applied to the elements within the window. The
  length of `weights` should be equal to the window size `(win_left + win_right + 1)`.
- `win`: A tuple `(win_left, win_right)` specifying the window size. Default is `(1, 1)`.
- `skip_centre`: If `true`, the current element is skipped during the calculation.

# Returns
The output vector `z` containing the weighted moving mean values.

# Example
```julia
x = [1.0, 2.0, 3.0, 4.0, 5.0]
w = [0.1, 0.8, 0.1]
z = similar(x, Float64)
weighted_movmean!(z, x, w, (1, 1); skip_centre=false)
```
"""
function weighted_movmean(x::AbstractVector{Tx}, w::AbstractVector{Tw},
  win::Tuple{Int,Int}=(1, 1); skip_centre=false) where {Tx<:Real,Tw<:Real}
  FT = Base.promote_op(/, Tx, Tw)
  z = zeros(FT, length(x))
  weighted_movmean!(z, x, w, win; skip_centre)
end

function weighted_movmean(x::AbstractVector{Tx}, w::AbstractVector{Tw}, halfwin::Int;
  skip_centre=false) where {Tx<:Real,Tw<:Real}
  weighted_movmean(x, w, (halfwin, halfwin); skip_centre)
end

function weighted_movmean!(z::AbstractVector{FT},
  x::AbstractVector{Tx}, w::AbstractVector{Tw}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false) where {FT<:Real,Tx<:Real,Tw<:Real}

  win_left, win_right = win
  ∑ = ∅ = FT(0)
  ∑w = ∅w = Tw(0)

  @inbounds @simd for i ∈ eachindex(x)
    ibeg = max(i - win_left, firstindex(x))
    iend = min(i + win_right, lastindex(x))

    ∑ = ∅
    ∑w = ∅w
    for j = ibeg:iend
      skip = skip_centre && i == j
      xᵢ = x[j]
      notnan = (xᵢ == xᵢ) && !skip
      ∑ += ifelse(notnan, xᵢ * w[j], ∅)
      ∑w += ifelse(notnan, w[j], 0)
    end
    z[i] = ∑ / ∑w
  end
  z
end
