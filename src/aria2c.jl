## 为了加速下载CMIP6 nc文件
# @time import Aria2_jll: aria2c_path as exe_aria2c
# https://docs.juliahub.com/Aria2_jll/DD75n/1.36.0+1/
exe_aria2c = "aria2c"

get_host(x::AbstractString) = str_extract(x, "(?<=://)[^\\/]*")

"""
    aria2c(infile, args="";
        j=5, s=5, x=5, outdir=".",
        verbose=false, debug=false, run=true)

# Installation

- `windows`: `scoop install aria2`

- `linux`: `sudo apt install aria2`


# Arguments

- `j`: `--max-concurrent-downloads=N` Set maximum number of parallel downloads for 
every static (HTTP/FTP) URL, torrent and metalink. 
See also --split and --optimize-concurrent-downloads options. 
Possible Values: 1-*, Default: 5, Tags: #basic

- `s`: `--split=N` Download a file using N connections. If more than N URIs 
are given, first N URIs are used and remaining URLs are used for backup. 
If less than N URIs are given, those URLs are used more than once so that 
N connections total are made simultaneously. The number of connections to the 
same host is restricted by the --max-connection-per-server option. See also the 
--min-split-size option. 
Possible Values: 1-*, Default: 5, Tags: #basic, #http, #ftp

- `x`: --max-connection-per-server=NUM The maximum number of connections to one 
server for each download. 
Possible Values: 1-16, Default: 1, Tags: #basic, #http, #ftp

- `timeout`: in seconds, default 10s. Notice that `timeout=120s` in aria2c by default.


# Examples

```julia
using Ipaper

infile = "/mnt/z/CMIP6/CMIP6_global_WB/urls.txt"
outdir = "/mnt/z/CMIP6/CMIP6_global_WB/raw"

infile_rem = aria2c_rem(infile; outdir)
aria2c(infile_rem, outdir; check_rem=false)
```
"""
function aria2c(infile="", args="";
  j=5, s=5, x=5, outdir=".",
  check_rem=true,
  hosts_bad=[],
  timeout=10,
  verbose=false, run=true)

  if (isa(infile, String) && isfile(infile))
    check_rem && (infile = aria2c_rem(infile; outdir))

    # rm bad hosts
    if !is_empty(hosts_bad)
      urls = readlines(infile)
      hosts = get_host.(urls)
      inds_good = map(x -> !(x in hosts_bad), hosts)
      urls = urls[inds_good]

      infile = gsub(infile, r".txt$", "_good.txt")
      writelines(urls, infile)
    end
    infile = "-i $infile"
  end
  cmd = `$exe_aria2c -j$j -s$s -x$x -t$timeout -c $infile -d $outdir $args`

  # Base.run(`$exe_aria2c --version`)
  !run && (verbose = true)
  verbose && println(cmd)
  run && Base.run(cmd)

  infile
end



file_exists(f) = filesize(f) > 1024 # > 1kb

function aria2c_file_temp(indir; subfix_temp=r".aria2$")
  fs_tmp = dir(indir, subfix_temp) # temp file
  fs_tmp = gsub(fs_tmp, subfix_temp, "")
  fs_tmp
end

function aria2c_file_finished(indir; subfix=r".nc$|.nc4$", subfix_temp=r".aria2$")
  fs_tmp = aria2c_file_temp(indir; subfix_temp)
  # rm aria2c temp files
  fs = dir(indir, subfix) #|.nc4$
  fs_finished = setdiff(fs, fs_tmp)
  fs_finished
end


function aria2c_rem(infile; outdir=".", verbose=true)

  fs_finished = aria2c_file_finished(outdir)
  infile_rem = gsub(infile, r".txt$", "_rem.txt")

  if length(fs_finished) > 0
    urls = readlines(infile)

    _, inds_x, inds = match2(basename.(fs_finished), basename.(urls))
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
    cp(infile, infile_rem)
  end
  infile_rem
end

function kill_app(app="aria2")
  run(`pkill -f $app -9`)
  nothing
end



export file_exists
export aria2c, aria2c_rem, kill_app

