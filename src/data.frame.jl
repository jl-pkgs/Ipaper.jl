using DataFrames
# using Ipaper

DataFrames.nrow(x::AbstractArray) = size(x, 1)
DataFrames.ncol(x::AbstractArray) = size(x, 2)

# rbind(args...) = cat(args..., dims = 1)
# cbind(args...) = cat(args..., dims = 2)
abind(args...; along=3) = cat(args..., dims=along)

# # rbind = vcat
rbind(args...; kw...) = vcat(args...; kw...)
# rbind(x) = x
# rbind(x::DataFrame,
#     y::Union{DataFrame,AbstractVecOrMat}; kw...) = begin
#     # @assert (ncol(x) == ncol(y))
#     x = as_dataframe(x)
#     y = as_dataframe(y, names(x))
#     vcat(x, y; kw...)
# end

# rbind(x::AbstractVecOrMat, y::DataFrame; kw...) = rbind(as_dataframe(x, names(y)), y; kw...)

# function rbind(x::DataFrame, args...; kw...)
#     x = as_dataframe(x)
#     if length(args) == 0
#         x
#     elseif length(args) == 1
#         rbind(x, args[1])
#     else
#         rbind(rbind(x, args[1]), args[2:end]...)
#     end
# end

# cbind = hcat # not work
cbind(args...; kw...) = hcat(args...; kw...)
cbind(x) = x
cbind(x::AbstractDataFrame, y::Union{AbstractDataFrame,AbstractVecOrMat}) =
    hcat(as_dataframe(x), as_dataframe(y); makeunique=true)
cbind(x::AbstractVecOrMat, y::AbstractDataFrame; kw...) = cbind(as_dataframe(x), y; kw...)

# by reference
function cbind(x::AbstractDataFrame, args...; kw...)
    x = as_dataframe(x)
    n = length(kw)
    if n > 0
        vars = keys(kw)
        for i = 1:n
            key = vars[i]
            val = kw[i]
            # @show key
            # @show val
            if !isa(val, AbstractArray) || length(val) == 1
                x[:, key] .= val
            else
                x[:, key] = val
            end
        end
    end
    if length(args) == 0
        x
    elseif length(args) == 1
        cbind(x, args[1])
    else
        cbind(cbind(x, args[1]), args[2:end]...)
    end
end

macro as_df(x)
    name = string(x)
    expr = :(DataFrame($name => $x))
    esc(expr)
end
export @as_df;

as_matrix(x::AbstractDataFrame) = Matrix(x)

as_dataframe(x::AbstractDataFrame, args...) = x
as_dataframe(x::AbstractVector) = @as_df(x)

as_dataframe(x::AbstractMatrix) = DataFrame(x, :auto)
function as_dataframe(x::AbstractVecOrMat, names::AbstractVector; kw...)
    DataFrame(x, names; kw...)
end

is_dataframe(d) = d isa DataFrame

# for data.frame by reference operation
function melt_list(list; kw...)
    if length(kw) > 0
        by = keys(kw)[1]
        vals = kw[1]
    else
        by = :I
        vals = 1:length(list)
    end

    for i = 1:length(list)
        d = list[i]
        if (d isa DataFrame)
            d[:, by] .= vals[i]
        end
    end
    ind = map(is_dataframe, list)
    vcat(list[ind]...)
end

# rename Duplicate variables in dt_merge
rename_varsDup(x::AbstractString, vars_dup::Vector, suffix="_x") = x in vars_dup ? x * suffix : x

"""
    $(TYPEDSIGNATURES)

```julia
d1 = DataFrame(A=1:3, B=4:6, C=7:9)
d2 = DataFrame(A=1:3, B=4:6, D=7:9)
d = dt_merge(d1, d2, by = "A", suffixes=["_tas", ".rh"])
d[:, "B.rh"]
```

seealso: [`leftjoin`](@ref), [`rightjoin`](@ref), [`innerjoin`](@ref), 
    [`outerjoin`](@ref)
"""
function dt_merge(x::AbstractDataFrame, y::AbstractDataFrame; by=nothing,
    all=false, all_x=all, all_y=all, makeunique=true, suffixes=["_x", "_y"], kw...)

    if by === nothing
        by = intersect(names(x), names(y))
    end
    by = String.(by) # Symbol not work in `setdiff`
    
    vars_dup = intersect(setdiff(names(x), by), setdiff(names(y), by))
    
    rename_x(x) = rename_varsDup(x, vars_dup, suffixes[1])
    rename_y(x) = rename_varsDup(x, vars_dup, suffixes[2])
    kw2 = (kw..., on=by, makeunique, renamecols=rename_x => rename_y)
    # @show kw2
    if !all
        if all_x
            leftjoin(x, y; kw2...)
        elseif all_y
            rightjoin(x, y; kw2...)
        else
            # all_x = f && all_y = f
            innerjoin(x, y; kw2...)
        end
    else
        outerjoin(x, y; kw2...)
    end
end

fread(file::AbstractString) = DataFrame(CSV.File(file))

"""
    fwrite(df, file; kw...)

```julia
df = DataFrame(A=1:3, B=4:6, C=7:9)
fwrite(df, "a.csv")
fwrite(df, "a.csv", append=true)

fread("a.csv")
```
"""
fwrite(df::AbstractDataFrame, file::AbstractString; append=false, kw...) = begin
    dirname(file) |> check_dir
    CSV.write(file, df; append=append, kw...)
end

# for data.frame by reference operation
function dataframe(; kw...)
    DataFrame(pairs(kw))
end
datatable = dataframe

# function list(; kw...)
#     Dict(pairs(kw))
# end

#! This version not work
# function datatable(args...; kw...)
#     params = args..., kw...
#     datatable(; params...)
# end
const DF = dataframe;

export rbind, cbind, abind, melt_list,
    fread, fwrite, dt_merge,
    is_dataframe,
    as_dataframe,
    # rename_varsDup,
    as_matrix, nrow, ncol,
    DataFrame, DF, names,
    datatable, dataframe

precompile(fread, (String,))
precompile(fread, (DataFrame, String))
