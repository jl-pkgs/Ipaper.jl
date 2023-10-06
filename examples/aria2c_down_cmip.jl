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
# infile = "/mnt/z/CMIP6/CMIP6_global_WB/urls.txt"
# outdir = "/mnt/z/CMIP6/CMIP6_global_WB/raw"
infile = "./urls_rem.txt"
outdir = "OUTPUT"

f2 = filter_date(infile)
# @time f_rem = aria2c_rem(infile; outdir)

# f_rem = infile
hosts_bad = []
hosts_bad = ["esg-dn2.nsc.liu.se", "esgf.bsc.es", "esgf-data.ucar.edu"]
f_left = aria2c(f2; outdir, check_rem=true, run=true, hosts_bad, timeout=10)
kill_app()


## 2. Check bad urls ------------------------------------------------------------
urls = readlines(f_left)
hosts = Ipaper.get_host.(urls)
table(hosts)


function NetCDFTools.CMIP.get_model(file, prefix="day_|mon_", postfix="_hist|_ssp|_piControl")
  str_extract(basename(file), "(?<=$prefix).*(?=$postfix)") #|> String
end

CMIP.get_model.(urls[1:2])

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
