var documenterSearchIndex = {"docs":
[{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"Pages = [\"Statistics.md\"]\nDepth = 3","category":"page"},{"location":"Statistics/#Quantile","page":"Statistics","title":"Quantile","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"NanQuantile_3d!\nIpaper.NanQuantile_low","category":"page"},{"location":"Statistics/#Ipaper.NanQuantile_3d!","page":"Statistics","title":"Ipaper.NanQuantile_3d!","text":"Arguments\n\nfun: reference function, quantile! or _nanquantile!\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.NanQuantile_low","page":"Statistics","title":"Ipaper.NanQuantile_low","text":"NanQuantile_low(A::AbstractArray{T,N};\n    probs::Vector=[0, 0.25, 0.5, 0.75, 1], dims::Integer=N, na_rm::Bool=true, dtype=nothing) where {T<:Real,N}\n\nNanQuantile_low(na_rm=rue) is 3~4 times faster than _nanquantile(na_rm=true)\n\nExamples\n\nusing Test\n\ndates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)\nntime = length(dates)\narr = rand(Float32, 140, 80, ntime)\narr2 = copy(arr)\n\n# default `na_rm=true`\n@test NanQuantile([1, 2, 3, NaN]; probs=[0.5, 0.9], dims=1) == [2.0, 2.8]\n\n@time r0 = _nanquantile(arr, dims=3) # low version\n@time r2_0 = NanQuantile_low(arr; dims=3, na_rm=false)\n@time r2_1 = NanQuantile_low(arr; dims=3, na_rm=true)\n\n@test r2_0 == r2_1\n@test r2_0 == 20\n@test arr2 == arr\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Statistics","page":"Statistics","title":"Statistics","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"movmean\nlinreg_simple\nlinreg_fast","category":"page"},{"location":"Statistics/#Ipaper.movmean","page":"Statistics","title":"Ipaper.movmean","text":"movmean(x::AbstractVector{T}, win::Tuple{Int,Int}=(1, 1); skip_centre=false) where {T<:Real}\n\nCompute the moving mean of the input vector x with a specified window size.\n\nArguments\n\nx::AbstractVector{T}: Input vector of type T where T is a subtype of Real.\nwin::Tuple{Int,Int}: A tuple specifying the window size (win_left, win_right). Default is (1, 1).\nskip_centre::Bool: If true, the center element is skipped in the mean calculation. Default is false.\n\nReturns\n\nA vector of the same length as x containing the moving mean values.\n\nExample\n\nx = [1.0, 2.0, 3.0, 4.0, 5.0]\nmovmean(x, (1, 1))  # returns [1.5, 2.0, 3.0, 4.0, 4.5]\nmovmean(x, (1, 1); skip_centre=true)  # returns [1.0, 2.0, 3.0, 4.0, 5.0]\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.linreg_simple","page":"Statistics","title":"Ipaper.linreg_simple","text":"linreg_simple(y::AbstractVector, x::AbstractVector; na_rm=false)\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#Ipaper.linreg_fast","page":"Statistics","title":"Ipaper.linreg_fast","text":"linreg_fast(y::AbstractVector, x::AbstractVector; na_rm=false)\n\n\n\n\n\n","category":"function"},{"location":"Statistics/#apply","page":"Statistics","title":"apply","text":"","category":"section"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"agg_time\nagg","category":"page"},{"location":"Statistics/#Ipaper.agg_time","page":"Statistics","title":"Ipaper.agg_time","text":"agg_time(A::AbstractArray{T,3}, by::Vector; parallel=true, progress=false, \n    fun=mean) where {T<:Real}\nagg_time(A::AbstractArray{T,3}; fact::Int=2, parallel=true, progress=false, \n  fun=mean) where {T<:Real}\n\n\n\n\n\n","category":"function"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"apply","category":"page"},{"location":"Statistics/#Ipaper.apply","page":"Statistics","title":"Ipaper.apply","text":"apply(A::AbstractArray; ...) -> Any\napply(\n    A::AbstractArray,\n    dims_by,\n    args...;\n    dims,\n    by,\n    fun,\n    combine,\n    parallel,\n    progress,\n    kw...\n) -> Any\n\n\nArguments\n\ndims_by: if by provided, the length of dims should be one!\ndims: used by mapslices\ncombine: if true, combine the result to a large array\n\nExamples\n\nusing Ipaper\nusing NaNStatistics\nusing Distributions\n\ndates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)\nyms = format.(dates, \"yyyy-mm\")\n\n## example 01, some as R aggregate\nx1 = rand(365)\napply(x1, 1, yms)\napply(x1, 1, by=yms)\n\n## example 02\nn = 100\nx = rand(n, n, 365)\n\nres = apply(x, 3, by=yms)\nsize(res) == (n, n, 12)\n\nres = apply(x, 3)\nsize(res) == (n, n)\n\n## example 03\ndates = make_date(2010):Day(1):make_date(2013, 12, 31)\nn = 10\nntime = length(dates)\nx = rand(n, n, ntime, 13)\n\nyears = year.(dates)\nres = apply(x, 3; by=years, fun=_nanquantile, combine=true, probs=[0.05, 0.95])\nobj_size(res)\n\nres = apply(x, 3; by=years, fun=mean, combine=true)\n\napply(x, 3; by = month.(dates), fun=slope_mk)\n\n\n\n\n\n","category":"function"},{"location":"Statistics/","page":"Statistics","title":"Statistics","text":"approx","category":"page"},{"location":"Statistics/#Ipaper.approx","page":"Statistics","title":"Ipaper.approx","text":"approx(x, y, xout; rule=2)\n\nApproximate the value of a function at a given point using linear interpolation.\n\nDateTime is also supported. But Date not!\n\nArguments\n\nx::AbstractVector{Tx}: The x-coordinates of the data points.\ny::AbstractVector{Ty}: The y-coordinates of the data points.\nxout::AbstractVector: The x-coordinates of the points to approximate.\nrule::Int=2: The interpolation rule to use. Default is 2.\n1: NaN\n2: nearest constant extrapolation\n3: linear extrapolation\n\n\n\n\n\n","category":"function"},{"location":"RBase/#R-Base","page":"R Base","title":"R Base","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"Pages = [\"RBase.md\"]\nDepth = 3","category":"page"},{"location":"RBase/#Strings","page":"R Base","title":"Strings","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"str_extract\nstr_extract_all\nstr_replace\ngrepl","category":"page"},{"location":"RBase/#Ipaper.str_extract","page":"R Base","title":"Ipaper.str_extract","text":"str_extract(x::AbstractString, pattern::AbstractString)\nstr_extract(x::Vector{<:AbstractString}, pattern::AbstractString)\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.str_extract_all","page":"R Base","title":"Ipaper.str_extract_all","text":"str_extract_all(\n    x::AbstractString,\n    pattern::Union{Regex, AbstractString}\n) -> Union{Vector{SubString{Base.AnnotatedString{String}}}, Vector{SubString{String}}}\n\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.str_replace","page":"R Base","title":"Ipaper.str_replace","text":"str_replace(x::AbstractString, pattern::AbstractString, replacement::AbstractString = \"\")\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.grepl","page":"R Base","title":"Ipaper.grepl","text":"grep(x::Union{AbstractString,Vector{<:AbstractString}},\n    pattern::AbstractString)::AbstractArray{Int,1}\ngrepl(x::Vector{<:AbstractString}, pattern::AbstractString)::AbstractArray{Bool,1}\ngrepl(x::AbstractString, pattern::AbstractString)\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Plots","page":"R Base","title":"Plots","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"merge_pdf\nshow_pdf","category":"page"},{"location":"RBase/#Ipaper.merge_pdf","page":"R Base","title":"Ipaper.merge_pdf","text":"merge_pdf(\"*.pdf\", output=\"Plot.pdf\")\n\nPlease install pdftk first. On Linux, sudo apt install pdftk-java.\n\nmerge multiple pdf files by pdftk\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.show_pdf","page":"R Base","title":"Ipaper.show_pdf","text":"open pdf file in SumatraPDF\n\n\n\n\n\n","category":"function"},{"location":"RBase/#cmd","page":"R Base","title":"cmd","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"dir\npath_mnt\nwritelines","category":"page"},{"location":"RBase/#Ipaper.dir","page":"R Base","title":"Ipaper.dir","text":"dir(path = \".\", pattern = \"\"; full_names = true, include_dirs = false, recursive = false)\n\nArguments:\n\npath\npattern\nfull_names\ninclude_dirs\nrecursive\n\nExample\n\ndir(\"src\", \"\\.jl$\")\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.path_mnt","page":"R Base","title":"Ipaper.path_mnt","text":"path_mnt(path = \".\")\n\nRelative path will kept the original format.\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.writelines","page":"R Base","title":"Ipaper.writelines","text":"writelines(\n    x::AbstractVector{<:AbstractString},\n    f::AbstractString;\n    mode,\n    eof\n)\n\n\nArguments\n\nmode: \n\nMode Description Keywords                    –––– ––––––––––– –––––––––––––––––––––––––   r    read        none                        w    write       write = true                r+   read, write read = true, write = true   w+   read, write read = true, write = true\n\n@seealso readlines\n\n! x 需要是string，不然文件错误\n\n\n\n\n\n","category":"function"},{"location":"RBase/#R-base","page":"R Base","title":"R base","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"duplicated\nlist\nmatch2","category":"page"},{"location":"RBase/#Ipaper.duplicated","page":"R Base","title":"Ipaper.duplicated","text":"duplicated(x::Vector{<:Real})\n\nx = [1, 2, 3, 4, 1]\nduplicated(x)\n# [0, 0, 0, 0, 1]\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.list","page":"R Base","title":"Ipaper.list","text":"list(keys::Vector{Symbol}, values)\nlist(keys::Vector{<:AbstractString}, values)\n\nExamples\n\nlist([:dw, :betaw, :swmax, :a, :c, :kh, :uh]\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.match2","page":"R Base","title":"Ipaper.match2","text":"match2(x, y)\n\nExamples\n\n## original version\nmds = [1, 4, 3, 5]\nmd = [1, 5, 6]\n\nfindall(r_in(mds, md))\nindexin(md, mds)\n\n## modern version\nx = [1, 2, 3, 3, 4]\ny = [0, 2, 2, 3, 4, 5, 6]\nmatch2(x, y)\n\nNote: match2 only find the element in y\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Missing","page":"R Base","title":"Missing","text":"","category":"section"},{"location":"RBase/","page":"R Base","title":"R Base","text":"drop_missing\nto_missing","category":"page"},{"location":"RBase/#Ipaper.drop_missing","page":"R Base","title":"Ipaper.drop_missing","text":"drop_missing\n\ndrop_missing(\n    x::AbstractArray{Union{Missing, T<:Real}}\n) -> Any\ndrop_missing(\n    x::AbstractArray{Union{Missing, T<:Real}},\n    replacement\n) -> Any\n\n\n\n\n\n\n","category":"function"},{"location":"RBase/#Ipaper.to_missing","page":"R Base","title":"Ipaper.to_missing","text":"to_missing(x::AbstractArray{T}, replacement=0)\n\nto_missing(x::AbstractArray{Union{T,Missing}}, replacement=0)\n\nto_missing!(x::AbstractArray{Union{T,Missing}}, replacement=0)\n\nconvert replacement to missing\n\nto_missing(\n    x::AbstractArray{T<:Real}\n) -> Union{CategoricalArrays.CategoricalArray, AbstractArray{Union{Missing, T}} where T<:Real}\nto_missing(\n    x::AbstractArray{T<:Real},\n    replacement\n) -> Union{CategoricalArrays.CategoricalArray, AbstractArray{Union{Missing, T}} where T<:Real}\n\n\nUsage\n\nto_missing(x)\nto_missing(x, replacement)\n\ndefined at /home/runner/work/Ipaper.jl/Ipaper.jl/src/missing.jl:29.\n\n\n\n\n\n","category":"function"},{"location":"Parallel/","page":"Parallel","title":"Parallel","text":"Pages = [\"Parallel.md\"]\nDepth = 3","category":"page"},{"location":"Parallel/#Parallel","page":"Parallel","title":"Parallel","text":"","category":"section"},{"location":"Parallel/","page":"Parallel","title":"Parallel","text":"par_map\npar_mapslices","category":"page"},{"location":"Parallel/#Ipaper.par_map","page":"Parallel","title":"Ipaper.par_map","text":"par_map(f, A, args...; kw...)\n\nExamples\n\nfunction f(x)\n  sleep(0.1)\n  x\nend\n\n# get_clusters()\n@time par_map(f, 1:10)\n@time map(f, 1:10)\n\n\n\n\n\n","category":"function"},{"location":"Parallel/#Ipaper.par_mapslices","page":"Parallel","title":"Ipaper.par_mapslices","text":"par_mapslices(f, A::AbstractArray{<:Real,N}, args...; dims=N, kw...)\n\nArguments\n\ndims: the dimension apply f\n\n@seealso mapslices\n\nExample\n\nusing Ipaper\nusing Distributions\n\nA = rand(100, 100, 30, 4)\nobj_size(A)\n\npar_mapslices(mean, A)\n\n# @time r = mapslices(slope_mk, A; dims=3);\n# @time r_par = par_mapslices(slope_mk, A; dims=3); # 5X faster\n\nTODO: par_mapslices is low efficiency\n\n\n\n\n\n","category":"function"},{"location":"Parallel/","page":"Parallel","title":"Parallel","text":"isCurrentWorker","category":"page"},{"location":"Parallel/#Ipaper.isCurrentWorker","page":"Parallel","title":"Ipaper.isCurrentWorker","text":"isCurrentWorker() -> Bool\nisCurrentWorker(i) -> Any\n\n\nExample\n\n!isCurrentWorker(i) && continue\n\n\n\n\n\n","category":"function"},{"location":"#Ipaper-in-Julia-(R-base-for-Julia)","page":"Introduction","title":"Ipaper in Julia (R base for Julia)","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"(Image: Stable) (Image: Dev) (Image: CI) (Image: Codecov)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Dongdong Kong","category":"page"},{"location":"#Installation","page":"Introduction","title":"Installation","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"using Pkg\nPkg.add(url=\"https://github.com/jl-spatial/Ipaper.jl\")","category":"page"},{"location":"Slope/","page":"Slope","title":"Slope","text":"Pages = [\"Slope.md\"]\nDepth = 3","category":"page"},{"location":"Slope/#Slope","page":"Slope","title":"Slope","text":"","category":"section"},{"location":"Slope/","page":"Slope","title":"Slope","text":"slope_mk\nslope_p","category":"page"},{"location":"Slope/#Ipaper.slope_mk","page":"Slope","title":"Ipaper.slope_mk","text":"slope_mk(y::AbstractVector, x::AbstractVector=1:length(y); ci=0.95)\n\nArguments\n\ny: numeric vector\nx: (optional) numeric vector\nci: critical value of autocorrelation\n\nReturn\n\nZ0    : The original (non corrected) Mann-Kendall test Z statistic.\npval0 : The original (non corrected) Mann-Kendall test p-value\nZ     : The new Z statistic after applying the correction\npval  : Corrected p-value after accounting for serial autocorrelation N/n*s Value of the correction factor, representing the quotient of the number of samples N divided by the effective sample size n*s\nslp   : Sen slope, The slope of the (linear) trend according to Sen test. slp is significant, if pval < alpha.\n\nReferences\n\nHipel, K.W. and McLeod, A.I. (1994), Time Series Modelling of Water Resources and Environmental Systems. New York: Elsevier Science.\nLibiseller, C. and Grimvall, A., (2002), Performance of partial Mann-Kendall tests for trend detection in the presence of covariates. Environmetrics, 13, 71–84, doi:10.1002/env.507.\n\nExample\n\nslope_mk([4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69])\n\nA = rand(100, 100, 30, 4)\n@time r = mapslices(slope_mk, A; dims=3);\n\n\n\n\n\n","category":"function"},{"location":"Slope/#Ipaper.slope_p","page":"Slope","title":"Ipaper.slope_p","text":"slope_p(y::AbstractVector, x::AbstractVector=1:length(y))\n\nReference\n\nhttps://zhuanlan.zhihu.com/p/642186978\n\nExample\n\nx = [1, 2, 3, 4, 5];\ny = [2, 4, 5, 4, 6];\nslope_p(y)\n\n\n\n\n\n","category":"function"}]
}
