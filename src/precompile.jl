precompile(path_mnt, (String, ))
precompile(factor, (Vector{Float64},))

precompile(movmean, (Vector{Float64}, ))
precompile(movmean, (Matrix{Float64}, ))

precompile(weighted_mean, (Vector{Float64}, Vector{Float64}))
precompile(weighted_mean, (Matrix{Float64}, Vector{Float64}))


precompile(check_file, (String, ))
precompile(check_dir, (String, ))


precompile(dir, (String, String))

precompile(str_extract, (String, String))
precompile(str_extract, (Vector{String}, String))

precompile(str_extract_all, (String, String))
precompile(str_extract_strip, (String, String))

precompile(str_replace, (String, String))

precompile(grep, (String, String))
precompile(grepl, (String, String))
precompile(grepl, (Vector{String}, String))
