# 该函数适用于mTRS_base, mTRS_full, mTRS_season
function subset_TRS_year(mTRS::AbstractArray{<:Real,3};
  ind_md, T_wl=nothing, year=nothing, kw...)

  _TRS = mTRS[:, :, ind_md]
  if T_wl !== nothing
    _TRS .+= T_wl[year]
  end
  _TRS
end

subset_TRS_year(pTRS::AbstractArray{<:Real,2}; kw...) = pTRS
subset_TRS_year(cTRS::Real; kw...) = cTRS



subset_TRS_prob(mTRS::AbstractArray{<:Real,4}, k) = @view mTRS[:, :, :, k]
subset_TRS_prob(pTRS::AbstractArray{<:Real,3}, k) = pTRS[:, :, k]
subset_TRS_prob(cTRS::Vector{<:Real}, k) = cTRS[k]
