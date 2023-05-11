# whether the file exist? If not, create its directory
function check_file(file; verbose = false)
    if (!isfile(file))
        dirname(file) |> mkpath
        false
    else
        verbose && printstyled("[warn] file exists: $(basename(file))\n"; color = :light_black)
        true
    end
end

# whether directory exist? If not, create it.
function check_dir(indir; verbose = false)
    if (!isdir(indir))
        mkpath(indir)
        false
    else
        verbose && printstyled("[warn] dir exists: $indir\n"; color = :light_black)
        true
    end
end



"""
    dir(path = ".", pattern = ""; full_names = true, include_dirs = false, recursive = false)

# Arguments:
- `path`
- `pattern`
- `full_names`
- `include_dirs`
- `recursive`

# Example
```julia
dir("src", "\\.jl\$")
```
"""
function dir(path=".", pattern=""; full_names=true, include_dirs=true, recursive=false)
    res = readdir(path_mnt(path), join=true) # also include directory

    dirs = filter(isdir, res)
    files = filter(isfile, res)

    if recursive
        files_deep = map(dirs) do x
            dir(x, pattern; full_names=full_names, include_dirs=include_dirs, recursive=recursive)
        end
        files = cat([files, files_deep...]..., dims=1)
    end

    if include_dirs
        files = [dirs; files]
    end
    if pattern != ""
        files = files[grep(basename.(files), pattern)]
    end
    files
end


export check_dir, check_file, dir
