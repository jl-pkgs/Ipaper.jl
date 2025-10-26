## 为了加速下载CMIP6 nc文件
# @time import Aria2_jll: aria2c_path as exe_aria2c
# https://docs.juliahub.com/Aria2_jll/DD75n/1.36.0+1/
exe_aria2c = "aria2c"

get_host(x::AbstractString) = str_extract(x, "(?<=://)[^\\/]*")

file_exists(f) = filesize(f) > 1024 # > 1kb


function aria2c_file_finished(outdir)
  fs = gsub.(dir(outdir), r".aria2$", "") |> unique # 这是所有文件
  fs_temp = gsub.(dir(outdir, r".aria2$"), r".aria2$", "") |> unique
  setdiff(fs, fs_temp)
end


"""
infile_rem = aria2c_rem(infile; outdir)
"""
function aria2c_rem(infile; outdir=".", verbose=true)
  fs_finished = aria2c_file_finished(outdir)
  infile_rem = gsub(infile, r".txt$", "_rem.txt")

  if length(fs_finished) > 0
    urls = readlines(infile)

    files_all = str_extract(basename.(urls), r"^(.*?)(?=\?|$)")
    _, inds_x, inds = match2(basename.(fs_finished), files_all)
    ind_rem = setdiff(1:length(urls), inds)
    urls_rem = urls[ind_rem]

    if verbose
      printstyled(@sprintf("[ok] %-16s: %4s finished, %4s left\n",
          basename(infile), length(inds), length(urls_rem)),
        color=:blue)
    end
    writelines(urls_rem, infile_rem)
  else
    printstyled("[ok] no files downloaded yet!\n", color=:blue)
    cp(infile, infile_rem, force=true)
  end
  infile_rem
end


"""
    aria2c(infile, args="";
        j=5, s=5, x=5, outdir=".",
        verbose=false, debug=false, run=true)

# Installation

- `windows`: `scoop install aria2`

- `linux`: `sudo apt install aria2`

# Examples

```julia
using Ipaper

infile = "/mnt/z/CMIP6/CMIP6_global_WB/urls.txt"
outdir = "/mnt/z/CMIP6/CMIP6_global_WB/raw"

@time f_rem = aria2c_rem(infile; outdir)

# hostS_bad = []
hosts_dead = ["esg-dn1.nsc.liu.se", "esg-dn2.nsc.liu.se", "esgf.bsc.es"]
f_left = aria2c(f_rem; outdir, check_rem=false, run=false, hosts_dead, timeout=10)
kill_app()

urls = readlines(f_rem)
hosts = get_host.(urls)
table(hosts)
```
"""
function aria2c(infile="", args="";
  j=5, s=5, x=5,
  outdir="OUTPUT",
  check_rem=true,
  hosts_dead=[],
  timeout=10,
  verbose=true, run=true, ignored...)

  check_dir(outdir)
  if isfile(infile)
    check_rem && (infile = aria2c_rem(infile; outdir))
    infile = rm_dead_hosts(infile, hosts_dead)

    cmd = `$exe_aria2c -j$j -s$s -x$x -t$timeout -c -i $infile -d $outdir $args`
  else
    cmd = `$exe_aria2c $infile -j$j -s$s -x$x -t$timeout -c -d $outdir $args`
  end

  !run && (verbose = true)
  verbose && println(cmd)
  run && Base.run(cmd)

  infile
end


function rm_dead_hosts(infile, hosts_dead=[])
  !is_empty(hosts_dead) || return infile

  urls = readlines(infile)
  hosts = get_host.(urls)
  inds_good = map(x -> !(x in hosts_dead), hosts)
  urls = urls[inds_good]

  infile = gsub(infile, r".txt$", "_good.txt")
  writelines(urls, infile)
  printstyled("[info] $(length(urls)) files left! \n", color=:blue, bold=true)
  return infile
end




function kill_app(app="aria2c")
  if is_linux()
    run(`pkill -f $app -9`)
  elseif is_windows()
    run(`taskkill /f /im $app.exe`)
  end
  nothing
end

export kill_app
export file_exists
export aria2c, aria2c_rem
