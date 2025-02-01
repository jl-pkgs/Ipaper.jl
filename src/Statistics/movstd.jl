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

function movstd(x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1);
  skip_centre=false, ddof::Int=1) where T<:Real
  FT = Base.promote_op(/, T, Int)
  z = similar(x, FT)
  movstd!(z, x, win; skip_centre, ddof)
end


export movstd
