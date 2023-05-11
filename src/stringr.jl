using Glob
export glob

Base.Regex(x::Regex) = x
StringOrRegex = Union{AbstractString,Regex}

"""
    str_extract(x::AbstractString, pattern::AbstractString)
    str_extract(x::Vector{<:AbstractString}, pattern::AbstractString)

    str_extract_all(x::AbstractString, pattern::AbstractString)
"""
function str_extract(x::AbstractString, pattern::StringOrRegex)
    r = match(Regex(pattern), basename(x))
    r === nothing ? "" : r.match
end

function str_extract(x::Vector{<:AbstractString}, pattern::StringOrRegex)
    str_extract.(x, pattern)
end

function str_extract_all(x::AbstractString, pattern::StringOrRegex)
    [x === nothing ? "" : x.match for x in eachmatch(Regex(pattern), basename(x))]
end

str_extract_strip(x::AbstractString, pattern::StringOrRegex) =
    strip(str_extract(x, pattern))

"""
    str_replace(x::AbstractString, pattern::AbstractString, replacement::AbstractString = "")
"""
function str_replace(x::AbstractString, pattern::StringOrRegex, replacement::AbstractString="")
    replace(x, pattern => replacement)
end

gsub = str_replace


"""
    grep(x::Union{AbstractString,Vector{<:AbstractString}},
        pattern::AbstractString)::AbstractArray{Int,1}
    grepl(x::Vector{<:AbstractString}, pattern::AbstractString)::AbstractArray{Bool,1}
    grepl(x::AbstractString, pattern::AbstractString)

"""
function grepl(x::AbstractString, pattern::StringOrRegex)
    r = match(Regex(pattern), x)
    r === nothing ? false : true
end

function grepl(x::Vector{<:AbstractString}, pattern::StringOrRegex)::AbstractArray{Bool,1}
    map(x) do x
        grepl(x, pattern)
    end
end

function grep(x::Union{AbstractString,Vector{<:AbstractString}},
    pattern::StringOrRegex)::AbstractArray{Int,1}

    grepl(x, pattern) |> findall
end




export str_extract, str_extract_all, str_extract_strip, str_replace,
    grep, grepl, gsub
