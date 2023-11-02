using Ipaper
using NetCDFTools
using NetCDFTools.CMIP


function filter_date(infile, year_end=2100)
  urls = readlines(infile)
  info = CMIPFiles_info(urls, include_year=true)
  info2 = @pipe info |> _[_.year_begin.<=year_end, :]

  fout = gsub(infile, ".txt", "_filterDate.txt")
  writelines(info2.file, fout)
  fout
end

## TODO: 尚需检查文件下载是否完整
infile = path_mnt("/mnt/z/CMIP6/CMIP6_global_WB/urls.txt")
outdir = path_mnt("/mnt/z/CMIP6/CMIP6_global_WB/raw")
# infile = "./urls_rem.txt"
outdir = "OUTPUT"

f2 = filter_date(infile)
@time f_rem = aria2c_rem(f2; outdir)

# f_rem = infile
hosts_bad = ["esgf.bsc.es"]
hosts_bad = ["esg-dn2.nsc.liu.se", "esgf.bsc.es", "esgf-data.ucar.edu"]

# f_rem = "Z:/CMIP6/CMIP6_global_WB/urls_filterDate_rem.txt"
f_rem = "./urls_filterDate_rem.txt"


f_left = aria2c(f_rem;
  j=5, s=1, x=5,
  outdir, check_rem=true, run=true, hosts_bad, timeout=20)
kill_app()

f_left = "./urls_filterDate_rem_rem.txt"

## 2. Check bad urls ------------------------------------------------------------
urls = readlines(f_left)
hosts = Ipaper.get_host.(urls)
table(hosts)


get_model.(urls[1:2])

info = CMIPFiles_info(urls)
s = CMIPFiles_summary(info)
# "esg-dn2.nsc.liu.se"        => 1185
# "esgf.bsc.es"               => 674
# "cmip.dess.tsinghua.edu.cn" => 6
# "esgf-data.ucar.edu"        => 44

# 8个model下载不成功
# Dict{SubString{String}, Int64} with 8 entries:
#   "CESM2-WACCM"       => 14
#   "CIESM"             => 6
#   "EC-Earth3-AerChem" => 165
#   "CESM2"             => 6
#   "EC-Earth3"         => 1014
#   "CESM2-WACCM-FV2"   => 8
#   "EC-Earth3-CC"      => 674
#   "CESM2-FV2"         => 8
