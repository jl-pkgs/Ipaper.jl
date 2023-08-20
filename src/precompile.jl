using PrecompileTools

# precompile(factor, (Vector{Float64},))
# precompile(movmean, (Vector{Float64}, ))
precompile(movmean, (Matrix{Float64}, ))
# precompile(weighted_mean, (Vector{Float64}, Vector{Float64}))
precompile(weighted_mean, (Matrix{Float64}, Vector{Float64}))


precompile(path_mnt, (String,))

precompile(check_file, (String, ))
precompile(check_dir, (String, ))
precompile(dir, (String, String))

# precompile(str_extract, (String, String))
# precompile(str_extract, (Vector{String}, String))
# precompile(str_extract_all, (String, String))
precompile(str_extract_strip, (String, String))

# precompile(str_replace, (String, String))
# precompile(grep, (String, String))
# precompile(grepl, (String, String))
# precompile(grepl, (Vector{String}, String))


@setup_workload begin
  str = "hello world! hello world!"
  strs = [str, "hello", "world"]
  dates = make_date(1960, 1, 1):Day(1):make_date(1961, 12, 31) |> collect
  
  @compile_workload begin
    str_extract(str, "hello")
    str_extract(strs, "hello")
    str_extract_all(str, "hello")
    str_extract_all.(strs, "hello")
    str_replace(str, "hello", "Hello")
    
    grep(strs, "hello")
    grepl(strs, "hello")
    
    # writelines(strs, "tmp")
    # rm("tmp")

    # fs = dir(".", ""; recursive=true) # error exists
    check_dir(".")
    path_mnt(".")

    for T in (Int, Float32, Float64) 
      x = rand(T, 10)
      w = rand(T, 10)

      factor(x)
      
      movmean(x)
      weighted_mean(x, w)
      
      # NanQuantile(x; probs=[0.1, 0.4])
      
      # mat = rand(T, 10, 4)
      # movmean(mat)
      # weighted_mean(mat, w)
    end

    @pipe str |> _

    ## precompile for cal_anomaly_quantile
    function test_anomaly2(; T=Float32, dims=(2,))
      ntime = length(dates)

      A = rand(T, dims..., ntime)
      kw = (; parallel=true, p1=1960, p2=1960, na_rm=false, probs=[0.5, 0.9])

      @time anom_season = cal_anomaly_quantile(A, dates; kw..., method="season")
      @time anom_base = cal_anomaly_quantile(A, dates; kw..., method="base")
      # @time anom_full = cal_anomaly_quantile(A, dates; kw..., method="full")

      @assert size(anom_base) == (dims..., ntime, length(kw.probs))
      @assert size(anom_base) == size(anom_season)
      # @assert size(anom_base) == size(anom_full)
    end
    # set_seed(1)
    # l_dims = [(), (2,), (2, 2), (2, 2, 2)]
    # for T in (Float32, Float64)
    #   for dims = l_dims
    #     test_anomaly2(; T, dims)
    #   end
    # end
  end
end
