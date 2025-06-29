import OrderedCollections: OrderedDict
export OrderedDict
# using LoopVectorization: @turbo

# function r_in(x::AbstractVector, y::AbstractVector)::BitVector
#   indexin(x, y) .!== nothing
# end
unlist(xs::AbstractVector) = map(x -> x, xs)
self(x) = x

function r_in(x::AbstractVector, y::AbstractVector)::BitVector
  res = falses(length(x))
  y_set = Set(y)

  @inbounds for i ∈ eachindex(x)
    res[i] = x[i] in y_set
  end
  return res
end

function r_in_low(x::AbstractVector, y::AbstractVector)::BitVector
  y_set = Set(y)
  in_y = falses(length(x))

  @inbounds for (i, xi) in enumerate(x)
    in_y[i] = xi in y_set
  end
  return in_y
end

function r_chunk(n::Int, nchunk=5)
  chunk = fld(n, nchunk) 
  map(i -> begin
    if i < nchunk
      _inds = (i-1)*chunk+1:i*chunk
    else
      _inds = (i-1)*chunk+1:n
    end
  end, 1:nchunk)
end

function r_chunk(x::AbstractVector, nchunk=5)
  n = length(x)
  inds = r_chunk(n, nchunk)
  map(i -> x[i], inds)
end


# purrr::map in julia
r_map(x, fun) = map(fun, x)

function r_map(x, name::N) where {N<:Union{String,Symbol}}
  map(x -> x[name], x)
end

# function r_map(x, names::Vector{N}) where {N<:Union{String,Symbol}}
#   vals = map(name -> begin
#       map(x -> x[name], x)
#     end, names)

#   DataFrame(vals, names)
# end

function r_split(lst::AbstractVector, by::AbstractVector)
  grps = unique(by) |> sort
  res = OrderedDict()
  for grp in grps
    inds = by .== grp
    res[grp] = lst[inds]
    # ans = Dict(grp => lst[inds])
    # ans = lst[inds]
    # push!(res, ans)
  end
  res
end

r_summary(x; digits=2) = nothing

function r_summary(x::AbstractArray{<:Real}; digits=2)
  T = eltype(x)
  probs = [0, 0.25, 0.5, 0.75, 1]

  x2 = filter(!isnan, x)
  if (length(x2) == 0)
    printstyled("empty array"; color=:red)
    return
  end

  n_nan = length(x) - length(x2)
  r = quantile(x2, probs)
  insert!(r, 4, mean(x2))
  r = round.(r, digits=digits)

  printstyled("Min\t 1st.Qu\t Median\t Mean\t 3rd.Qu\t Max\t NA's\n"; color=:blue)
  printstyled("$(r[1])\t $(r[2])\t $(r[3])\t $(r[4])\t $(r[5])\t $(r[6])\t $(n_nan)\n"; color=:blue)
  return nothing
end


letters(i::Int) = string('a' + i - 1)
LETTERS(i::Int) = string('A' + i - 1)

letters(I::AbstractVector{<:Integer}) = letters.(I)
LETTERS(I::AbstractVector{<:Integer}) = LETTERS.(I)

export r_in, r_in_low, r_chunk, r_map, r_split, r_summary
export letters, LETTERS
export unlist, self
