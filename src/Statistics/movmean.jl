function movmean!(z::AbstractVector, x::AbstractVector, halfwin::Integer = 2; fun=mean)
    n = length(x)
    @inbounds for i = 1:n
        i_begin = i <= halfwin ? 1 : i - halfwin
        i_end = i <= n - halfwin ? i + halfwin : n
        z[i] = fun(@view x[i_begin:i_end]) # 节省5倍内存
        # z[i] = mean(x[i_begin:i_end])
    end
    z
end

function movmean(x::AbstractVector, halfwin::Integer=2; fun=mean, FT=Float64) 
    n = length(x)
    z = zeros(FT, n)
    movmean!(z, x, halfwin; fun=fun)
end

# multiple dimension case
"""
    $(TYPEDSIGNATURES)

moving mean average
"""
function movmean(x::AbstractArray, halfwin::Integer=2; dim=3, fun=mean, FT=Float64)
    @assert length(dim) == 1 "The length of `dim` should be 1!"

    n = size(x, dim)
    zi = zeros(FT, n)
    mapslices(xi -> movmean!(zi, xi, halfwin; fun=fun), x; dims=dim)
end

## the weighted version --------------------------------------------------------

weighted_mean(x::AbstractVector, w::AbstractVector) = sum(x .* w) / sum(w)

# 4 times slower
function weighted_movmean!(z::AbstractVector, x::AbstractVector, w::AbstractVector, 
    halfwin::Integer=2; fun=weighted_mean)

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

function weighted_movmean(x::AbstractArray, w::AbstractVector, halfwin::Integer=2;
    fun=weighted_mean, FT=Float64)

    n = length(x)
    z = zeros(FT, n)
    weighted_movmean!(z, x, w, halfwin; fun=fun)
end
