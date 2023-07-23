var documenterSearchIndex = {"docs":
[{"location":"Climate/","page":"Climate","title":"Climate","text":"Pages = [\"index.md\"]\nDepth = 3","category":"page"},{"location":"Climate/#Thresholds","page":"Climate","title":"Thresholds","text":"","category":"section"},{"location":"Climate/","page":"Climate","title":"Climate","text":"cal_anomaly_quantile\ncal_anomaly_clim\ncal_threshold","category":"page"},{"location":"Climate/#Ipaper.cal_anomaly_quantile","page":"Climate","title":"Ipaper.cal_anomaly_quantile","text":"cal_anomaly_quantile(\n    A::AbstractArray{T<:Real},\n    dates;\n    parallel,\n    use_mov,\n    na_rm,\n    method,\n    p1,\n    p2,\n    fun,\n    probs,\n    options...\n) -> Any\n\n\nCalculate the anomaly of a 3D array of temperature data.\n\nArguments\n\nA      : the 3D array of temperature data\ndates    : an array of dates corresponding to the temperature data\nparallel : whether to use parallel processing (default true)\nuse_mov  : whether to use a moving window to calculate the threshold (default true)\nmethod   : the method to use for calculating the threshold, one of [\"full\", \"season\", \"base\"] (default \"full\")\nprobs    : default [0.5]\np1       : the start year for the reference period (default 1981)\np2       : the end year for the reference period (default 2010)\nfun      : the function used to calculate the anomaly (default _exceed)\n\nReturns\n\nAn array of the same shape as A containing the temperature anomaly.\n\nReferences\n\nVogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020). Development of Future Heatwaves for Different Hazard Thresholds. Journal of Geophysical Research: Atmospheres, 125(9). https://doi.org/10.1029/2019JD032070\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_anomaly_clim","page":"Climate","title":"Ipaper.cal_anomaly_clim","text":"cal_anomaly_clim(\n    A::AbstractArray{T<:Real},\n    dates;\n    parallel,\n    use_mov,\n    method,\n    p1,\n    p2,\n    fun_clim,\n    fun_anom\n) -> Any\n\n\nCalculate the anomaly of an array relative to its climatology.\n\nArguments\n\nA::AbstractArray{T}: The input array to calculate the anomaly of.\ndates: The dates corresponding to the input array.\nparallel::Bool=true: Whether to use parallel processing.\nuse_mov=true: Whether to use a moving window to calculate the climatology.\nmethod=\"full\": The method to use for calculating the climatology. Can be \"base\", \"season\", or \"full\".\np1=1981: The start year for the period to use for calculating the climatology.\np2=2010: The end year for the period to use for calculating the climatology.\nfun_clim=nanmean: The function to use for calculating the climatology.\nfun_anom=_exceed: The function to use for calculating the anomaly.\n\nReturns\n\nanom: The anomaly of the input array relative to its climatology.\n\nExample\n\nusing Ipaper\n\n# Generate some sample data\nA = rand(365, 10)\ndates = Date(2000, 1, 1):Day(1):Date(2000, 12, 31)\n\n# Calculate the anomaly relative to the climatology\nanom = cal_anomaly_clim(A, dates; method=\"base\")\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_threshold","page":"Climate","title":"Ipaper.cal_threshold","text":"cal_threshold(\n    A::AbstractArray{T<:Real},\n    dates;\n    parallel,\n    use_mov,\n    na_rm,\n    method,\n    p1,\n    p2,\n    probs,\n    options...\n) -> Any\n\n\nCalculate the threshold value for a given dataset A and dates. The threshold value is calculated based on the specified method.\n\nArguments\n\nA::AbstractArray{T}: The input data array.\ndates: The dates corresponding to the input data array.\nparallel::Bool=true: Whether to use parallel computation.\nuse_mov::Bool=true: Whether to use moving window.\nna_rm::Bool=true: Whether to remove missing values.\nmethod::String=\"full\": Possible values are \"base\", \"season\", and \"full\".\np1::Int=1981: The start year for the reference period.\np2::Int=2010: The end year for the reference period.\nprobs::Vector{Float64}=[0.5]: The probability levels to use for calculating the threshold value.\noptions...: Additional options to pass to the underlying functions.\n\nReturns\n\nFor different methods: \n\nfull: Array with the dimension of (dims..., ntime, nprob)\nbase: Array with the dimension of (dims..., 366, nprob)\nseason: Array with the dimension of (dims..., nyear)\n\nExamples\n\ndates = Date(2010, 1):Day(1):Date(2020, 12, 31);\nntime = length(dates)\ndata = rand(10, ntime);\ncal_threshold(data, dates; p1=2010, p2=2015, method=\"full\")\n\n\n\n\n\n","category":"function"},{"location":"Climate/","page":"Climate","title":"Climate","text":"_cal_anomaly_3d","category":"page"},{"location":"Climate/#Ipaper._cal_anomaly_3d","page":"Climate","title":"Ipaper._cal_anomaly_3d","text":"_cal_anomaly_3d(\n    A::AbstractArray{T<:Real, 3},\n    TRS::AbstractArray{T<:Real, 3},\n    dates;\n    T_wl,\n    fun_anom,\n    ignored...\n) -> Any\n\n\n\n\n\n\n","category":"function"},{"location":"Climate/","page":"Climate","title":"Climate","text":"cal_mTRS_base\ncal_mTRS_full\n\ncal_climatology_base\ncal_climatology_full","category":"page"},{"location":"Climate/#Ipaper.cal_mTRS_base","page":"Climate","title":"Ipaper.cal_mTRS_base","text":"cal_mTRS_base(\n    arr::AbstractArray{T<:Real, N},\n    dates;\n    dims,\n    use_quantile,\n    fun!,\n    probs,\n    dtype,\n    p1,\n    p2,\n    kw...\n) -> AbstractArray{T} where T<:Real\n\n\nMoving Threshold for Heatwaves Definition\n\nArguments\n\ntype: The matching type of the moving doys, \"md\" (default) or \"doy\".\n\nReturn\n\nTRS: in the dimension of [nlat, nlon, ndoy, nprob]\n\nReferences\n\nVogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020). Development of Future Heatwaves for Different Hazard Thresholds. Journal of Geophysical Research: Atmospheres, 125(9). https://doi.org/10.1029/2019JD032070\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_mTRS_full","page":"Climate","title":"Ipaper.cal_mTRS_full","text":"cal_mTRS_full(\n    arr::AbstractArray{T<:Real, N},\n    dates;\n    dims,\n    width,\n    verbose,\n    use_quantile,\n    fun!,\n    use_mov,\n    probs,\n    kw...\n) -> Any\n\n\nMoving Threshold for Heatwaves Definition\n\nArguments\n\nuse_mov: Boolean (default true). \nif true, 31*15 values will be used to calculate threshold for each grid; \nif false, the input arr is smoothed first, then only 15 values will be  used to calculate threshold.\n\n!!! 必须是完整的年份，不然会出错\n\nReferences\n\nVogel, M. M., Zscheischler, J., Fischer, E. M., & Seneviratne, S. I. (2020). Development of Future Heatwaves for Different Hazard Thresholds. Journal of Geophysical Research: Atmospheres, 125(9). https://doi.org/10.1029/2019JD032070\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_climatology_base","page":"Climate","title":"Ipaper.cal_climatology_base","text":"cal_climatology_base(\n    A::AbstractArray{T<:Real},\n    dates;\n    fun!,\n    kw...\n) -> AbstractArray{T} where T<:Real\n\n\nCalculate the climatology of a dataset A based on the dates.\n\nThe climatology is the long-term average of a variable over a specific period of time. This function calculates the climatology of the input dataset A based on the dates dates. The calculation is performed by applying a function fun! to a moving window of the data.\n\nArguments:\n\nA            : :AbstractArray{T}: the input dataset, where T is a subtype of Real.\ndates       : the dates associated with the input dataset, as a vector of Date objects.\nfun!        : the function to apply to the moving window of the data. It should take an input array and return a scalar.\nuse_quantile: default false, a boolean indicating whether to use a quantile-based filter to remove outliers.\np1, p2    : the references period\n\nReturns:\n\na matrix of the same size as A, containing the climatology values.\n\nExample:\n\nusing Dates\nA = rand(365, 10)  # simulate a year of daily data for 10 variables\ndates = Date(2022, 1, 1):Day(1):Date(2022, 12, 31)\nclim = cal_climatology_base(A, dates; fun! = mean)\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_climatology_full","page":"Climate","title":"Ipaper.cal_climatology_full","text":"cal_climatology_full(\n    A::AbstractArray{T<:Real},\n    dates;\n    fun!,\n    kw...\n) -> Any\n\n\n\n\n\n\n","category":"function"},{"location":"Climate/","page":"Climate","title":"Climate","text":"Ipaper.cal_mTRS_base!\nIpaper.cal_mTRS_base3!","category":"page"},{"location":"Climate/#Ipaper.cal_mTRS_base!","page":"Climate","title":"Ipaper.cal_mTRS_base!","text":"cal_mTRS_base!(\n    Q::AbstractArray{T<:Real},\n    arr::AbstractArray{T<:Real, N},\n    mmdd;\n    dims,\n    fun,\n    probs,\n    parallel,\n    halfwin,\n    use_mov,\n    ignore...\n) -> AbstractArray{T} where T<:Real\n\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_mTRS_base3!","page":"Climate","title":"Ipaper.cal_mTRS_base3!","text":"cal_mTRS_base3!(\n    Q::AbstractArray,\n    data::AbstractArray{T<:Real, 3},\n    mmdd;\n    dims,\n    probs,\n    parallel,\n    halfwin,\n    use_mov,\n    method_q,\n    na_rm,\n    ignore...\n) -> AbstractArray\n\n\n\n\n\n\n","category":"function"},{"location":"Climate/","page":"Climate","title":"Climate","text":"cal_yearly_Tair\ncal_warming_level","category":"page"},{"location":"Climate/#Ipaper.cal_yearly_Tair","page":"Climate","title":"Ipaper.cal_yearly_Tair","text":"Calculate yearly air temperature.\n\nDescription\n\nwe use the fixed thresholds and add the seasonal warming signal. Thus, thresholds are defined as a fixed baseline (such as for the fixed threshold) plus seasonally moving mean warming of the corresponding future climate based on the 31-year moving mean of the warmest three months.\n\nDetails\n\nThis function calculates the yearly air temperature based on the input temperature data and dates. If only_summer is true, it only calculates the temperature for summer months. The function applies the calculation along the specified dimensions.\n\nArguments\n\nA::AbstractArray{T,N}: input array of temperature data.\ndates: array of dates corresponding to the temperature data.\ndims=N: dimensions to apply the function along.\nonly_summer=false: if true, only calculate temperature for summer months.\n\nReturns\n\nT_year: array of yearly temperature data.\n\n\n\n\n\n","category":"function"},{"location":"Climate/#Ipaper.cal_warming_level","page":"Climate","title":"Ipaper.cal_warming_level","text":"cal_warming_level(\n    A::AbstractArray{T<:Real, N},\n    dates;\n    p1,\n    p2,\n    dims,\n    only_summer\n) -> Any\n\n\n\n\n\n\n","category":"function"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"Pages = [\"Statistics.md\"]\nDepth = 3","category":"page"},{"location":"Statistics/#Quantile","page":"Statistics","title":"Quantile","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"NanQuantile_3d!\nIpaper.NanQuantile_low","category":"page"},{"location":"Statistics/#Ipaper.NanQuantile_3d!","page":"Statistics","title":"Ipaper.NanQuantile_3d!","text":"Arguments\n\nfun: reference function, quantile! or _nanquantile!\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.NanQuantile_low","page":"Statistics","title":"Ipaper.NanQuantile_low","text":"NanQuantile_low(A::AbstractArray{T,N};\n    probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N, na_rm::Bool=true, dtype=nothing) where {T<:Real,N}\n\nNanQuantile_low(na_rm=rue) is 3~4 times faster than _nanquantile(na_rm=true)\n\nExamples\n\nusing Test\n\ndates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)\nntime = length(dates)\narr = rand(Float32, 140, 80, ntime)\narr2 = copy(arr)\n\n# default `na_rm=true`\n@test NanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]\n\n@time r0 = _nanquantile(arr, dims=3) # low version\n@time r2_0 = NanQuantile_low(arr; dims=3, na_rm=false)\n@time r2_1 = NanQuantile_low(arr; dims=3, na_rm=true)\n\n@test r2_0 == r2_1\n@test r2_0 == 20\n@test arr2 == arr\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Statistics","page":"Statistics","title":"Statistics","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"movmean\nlinreg_simple\nlinreg_fast","category":"page"},{"location":"Statistics/#Ipaper.movmean","page":"Statistics","title":"Ipaper.movmean","text":"movmean(x::AbstractArray) -> AbstractVector\nmovmean(\n    x::AbstractArray,\n    halfwin::Integer;\n    dims,\n    fun,\n    FT\n) -> AbstractVector\n\n\nmoving mean average\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.linreg_simple","page":"Statistics","title":"Ipaper.linreg_simple","text":"linreg_simple(y::AbstractVector, x::AbstractVector; na_rm=false)\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.linreg_fast","page":"Statistics","title":"Ipaper.linreg_fast","text":"linreg_fast(y::AbstractVector, x::AbstractVector; na_rm=false)\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#apply","page":"Statistics","title":"apply","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"apply","category":"page"},{"location":"Statistics/#Ipaper.apply","page":"Statistics","title":"Ipaper.apply","text":"apply(x::AbstractArray) -> Any\napply(\n    x::AbstractArray,\n    dims,\n    args...;\n    by,\n    fun,\n    combine,\n    kw...\n) -> Any\n\n\nArguments\n\ndims: if by provided, the length of dims should be one!\n\nExamples\n\ndates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)\nyms = format.(dates, \"yyyy-mm\")\n\n## example 01, some as R aggregate\nx1 = rand(365)\napply(x1, 1, yms)\napply(x1, 1, by=yms)\n\n## example 02\nn = 100\nx = rand(n, n, 365)\n\nres = apply(x, 3, by=yms)\nsize(res) == (n, n, 12)\n\nres = apply(x, 3)\nsize(res) == (n, n)\n\n## example 03\ndates = make_date(2010):Day(1):make_date(2013, 12, 31)\nn = 100\nntime = length(dates)\nx = rand(n, n, ntime)\n\nyears = year.(dates)\nres = apply(x, 3; by=years, fun=nanquantile, combine=true, probs=[0.05, 0.95])\nobj_size(res)\n\nres = apply(x, 3; by=years, fun=nanmean, combine=true)\n\n\n\n\n\n","category":"function"},{"location":"RBase/#R-Base","page":"R Base","title":"R Base","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"Pages = [\"RBase.md\"]\nDepth = 3","category":"page"},{"location":"RBase/#Strings","page":"R Base","title":"Strings","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"str_extract\nstr_extract_all\nstr_replace\ngrepl","category":"page"},{"location":"RBase/#Ipaper.str_extract","page":"R Base","title":"Ipaper.str_extract","text":"str_extract(x::AbstractString, pattern::AbstractString)\nstr_extract(x::Vector{<:AbstractString}, pattern::AbstractString)\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.str_extract_all","page":"R Base","title":"Ipaper.str_extract_all","text":"str_extract_all(\n    x::AbstractString,\n    pattern::Union{Regex, AbstractString}\n) -> Vector{SubString{String}}\n\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.str_replace","page":"R Base","title":"Ipaper.str_replace","text":"str_replace(x::AbstractString, pattern::AbstractString, replacement::AbstractString = \"\")\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.grepl","page":"R Base","title":"Ipaper.grepl","text":"grep(x::Union{AbstractString,Vector{<:AbstractString}},\n    pattern::AbstractString)::AbstractArray{Int,1}\ngrepl(x::Vector{<:AbstractString}, pattern::AbstractString)::AbstractArray{Bool,1}\ngrepl(x::AbstractString, pattern::AbstractString)\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Plots","page":"R Base","title":"Plots","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"merge_pdf\nshow_pdf","category":"page"},{"location":"RBase/#Ipaper.merge_pdf","page":"R Base","title":"Ipaper.merge_pdf","text":"merge_pdf(\"*.pdf\", output=\"Plot.pdf\")\n\nPlease install pdftk first. On Linux, sudo apt install pdftk-java.\n\nmerge multiple pdf files by pdftk\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.show_pdf","page":"R Base","title":"Ipaper.show_pdf","text":"open pdf file in SumatraPDF\n\n\n\n\n\n","category":"function"},{"location":"RBase/#cmd","page":"R Base","title":"cmd","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"dir\npath_mnt\nwritelines","category":"page"},{"location":"RBase/#Ipaper.dir","page":"R Base","title":"Ipaper.dir","text":"dir(path = \".\", pattern = \"\"; full_names = true, include_dirs = false, recursive = false)\n\nArguments:\n\npath\npattern\nfull_names\ninclude_dirs\nrecursive\n\nExample\n\ndir(\"src\", \"\\.jl$\")\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.path_mnt","page":"R Base","title":"Ipaper.path_mnt","text":"path_mnt(path = \".\")\n\nRelative path will kept the original format.\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.writelines","page":"R Base","title":"Ipaper.writelines","text":"writelines(\n    x::AbstractVector{<:AbstractString},\n    f;\n    mode,\n    eof\n) -> Any\n\n\nArguments\n\nmode: \n\nMode Description Keywords                    –––– ––––––––––– –––––––––––––––––––––––––   r    read        none                        w    write       write = true                r+   read, write read = true, write = true   w+   read, write read = true, write = true\n\n@seealso readlines\n\n! x 需要是string，不然文件错误\n\n\n\n\n\n","category":"function"},{"location":"RBase/#R-base","page":"R Base","title":"R base","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"duplicated\nlist\nmatch2","category":"page"},{"location":"RBase/#Ipaper.duplicated","page":"R Base","title":"Ipaper.duplicated","text":"duplicated(x::Vector{<:Real})\n\nx = [1, 2, 3, 4, 1]\nduplicated(x)\n# [0, 0, 0, 0, 1]\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.list","page":"R Base","title":"Ipaper.list","text":"list(keys::Vector{Symbol}, values)\nlist(keys::Vector{<:AbstractString}, values)\n\nExamples\n\nlist([:dw, :betaw, :swmax, :a, :c, :kh, :uh]\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.match2","page":"R Base","title":"Ipaper.match2","text":"match2(x, y)\n\nExamples\n\n## original version\nmds = [1, 4, 3, 5]\nmd = [1, 5, 6]\n\nfindall(r_in(mds, md))\nindexin(md, mds)\n\n## modern version\nx = [1, 2, 3, 3, 4]\ny = [0, 2, 2, 3, 4, 5, 6]\nmatch2(x, y)\n\nNote: match2 only find the element in y\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Missing","page":"R Base","title":"Missing","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"drop_missing\nto_missing","category":"page"},{"location":"RBase/#Ipaper.drop_missing","page":"R Base","title":"Ipaper.drop_missing","text":"drop_missing\n\ndrop_missing(\n    x::AbstractArray{Union{Missing, T<:Real}}\n) -> Any\ndrop_missing(\n    x::AbstractArray{Union{Missing, T<:Real}},\n    replacement\n) -> Any\n\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.to_missing","page":"R Base","title":"Ipaper.to_missing","text":"to_missing(x::AbstractArray{T}, replacement=0)\n\nto_missing(x::AbstractMissArray{T}, replacement=0)\n\nto_missing!(x::AbstractMissArray{T}, replacement=0)\n\nconvert replacement to missing\n\nto_missing(x::AbstractArray{T<:Real}) -> Any\nto_missing(x::AbstractArray{T<:Real}, replacement) -> Any\n\n\nUsage\n\nto_missing(x)\nto_missing(x, replacement)\n\ndefined at /home/runner/work/Ipaper.jl/Ipaper.jl/src/missing.jl:49.\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Parallel","page":"R Base","title":"Parallel","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"isCurrentWorker","category":"page"},{"location":"RBase/#Ipaper.isCurrentWorker","page":"R Base","title":"Ipaper.isCurrentWorker","text":"isCurrentWorker() -> Bool\nisCurrentWorker(i) -> Any\n\n\nExample\n\nif !isCurrentWorker(i); continue; end\n\n\n\n\n\n","category":"function"},{"location":"#Ipaper-in-Julia-(R-base-for-Julia)","page":"Introduction","title":"Ipaper in Julia (R base for Julia)","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"(Image: Stable) (Image: Dev) (Image: CI) (Image: Codecov)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Dongdong Kong","category":"page"},{"location":"#Installation","page":"Introduction","title":"Installation","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"using Pkg\nPkg.add(url=\"https://github.com/jl-spatial/Ipaper.jl\")","category":"page"}]
}
