"""
    movstd!(z::AbstractVector{FT}, x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
          skip_centre=false, ddof=1) where {FT<:Real, T<:Real}

Calculate the moving standard deviation of the input vector `x` using the window defined by
`win` and store the result in the preallocated output vector `z`.

# Arguments
- `z`: Preallocated output vector to store the computed standard deviation values.
- `x`: Input vector of real numbers.
- `win`: A tuple `(win_left, win_right)` specifying the window size. Default is `(1, 1)`.
- `skip_centre`: If `true`, the current element is skipped during the calculation.
- `ddof`: Delta degrees of freedom for variance calculation. The variance is computed as
  `(∑x² - ∑x*μ) / (N - ddof)`.

# Returns
The output vector `z` containing the moving standard deviation. If the number of valid values
in the window is not greater than `ddof`, `NaN` is assigned to that position.

# Example
```julia
x = [1.0, 2.0, 3.0, 4.0, 5.0]
z = similar(x, Float64)
movstd!(z, x, (1, 1); skip_centre=false, ddof=1)
```
"""
function movstd(x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false, ddof::Int=1) where T<:Real
  FT = Base.promote_op(/, T, Int)
  z = similar(x, FT)
  movstd!(z, x, win; skip_centre, ddof)
end

function movstd(x::AbstractVector{T}, halfwin::Int;
  skip_centre=false, ddof::Int=1) where T<:Real
  movstd(x, (halfwin, halfwin); skip_centre, ddof)
end

function movstd!(z::AbstractVector{FT}, x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false, ddof::Int=1) where {FT<:Real,T<:Real}
  win_left, win_right = win
  ∅ = FT(0)
  ∑x = ∑x² = ∅
  ∑w = 0

  @inbounds @simd for i ∈ eachindex(x)
    ibeg = max(i - win_left, firstindex(x))
    iend = min(i + win_right, lastindex(x))
    ∑x = ∅
    ∑x² = ∅
    ∑w = 0

    # First pass: compute sum and sum of squares
    for j = ibeg:iend
      skip = skip_centre && i == j
      xⱼ = x[j]
      notnan = (xⱼ == xⱼ) && !skip

      ∑x += ifelse(notnan, xⱼ, ∅)
      ∑x² += ifelse(notnan, xⱼ^2, ∅)
      ∑w += ifelse(notnan, 1, 0)
    end

    # Compute variance and std
    if ∑w > ddof
      μ = ∑x / ∑w
      z[i] = sqrt(max((∑x² - ∑x * μ) / (∑w - ddof), ∅))
    else
      z[i] = FT(NaN)
    end
  end
  z
end


export movstd
