# 针对性的写一个最高性能的Quantile
# 两次@view的嵌套会导致速度变慢；避免这种操作，可以获得极致的速度
function quantile_3d!(q::AbstractArray, x::AbstractArray; probs=[0, 0.25, 0.5, 0.75, 1], dims=3)
  # @assert length(dims) == 1 "The length of `dims` should be 1!"
  ntime = size(x, dims)
  nrow, ncol, ntime = size(x)
  zi = zeros(eltype(x), ntime)
  nprob = length(probs)
  _qi = zeros(eltype(x), nprob)

  @inbounds for i in 1:nrow, j = 1:ncol
    for t = eachindex(zi)
      zi[t] = x[i, j, t]
    end
    # qi = @view q[i, j, :]
    # xi = @view x[i, j, :]
    # copy!(zi, xi) # copy xi to zi
    Statistics.quantile!(_qi, zi, probs)
    for k = 1:nprob
      q[i, j, k] = _qi[k]
    end
  end
end

function quantile_nd(x::AbstractArray, probs=[0, 0.25, 0.5, 0.75, 1]; dims=3)
  # @assert length(dims) == 1 "The length of `dims` should be 1!"
  n = size(x, dims)
  zi = zeros(eltype(x), n)
  mapslices(xi -> begin
      copy!(zi, xi) # copy xi to zi
      Statistics.quantile!(zi, probs)
    end, x; dims=dims)
end
