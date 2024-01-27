function app_cdo(; options=`-f nc4 -z zip_1`, path="/opt/miniconda3/bin/cdo", help=false)
  wsl = (is_wsl() || is_windows()) ? `wsl` : ``
  help &&run(`$wsl $path -v`)
  `$wsl $path $options`
end

function cdo_grid(x::AbstractVector, y::AbstractVector; 
  fout="grid.txt", verbose=true)

  grid = """
  gridtype = lonlat
  xsize = $(length(x))
  ysize = $(length(y))
  xfirst = $(minimum(x))
  xinc = 1
  yfirst = $(minimum(y))
  yinc = 1"""

  verbose && println(grid)
  writelines([grid], fout)
  fout
end

function cdo_grid(range, cellsize, mid::Bool=true; fout="grid.txt", kw...)
  delta = mid ? cellsize / 2 : 0
  x = range[1]+delta:cellsize:range[2]
  y = range[3]+delta:cellsize:range[4]
  cdo_grid(x, y; fout, kw...)
end

function cdo_bilinear(fin, fout, fgrid; verbose=false, kw...)
  cdo = app_cdo(; kw...)
  cmd = `$cdo remapbil,$fgrid $fin $fout`

  verbose && println(cmd)
  run(cmd)
  nothing
end

function cdo_apply(fin, fout; fun="yearmean", kw...)
  cdo = app_cdo(; kw...)
  cmd = `$cdo $fun,$fgrid $fin $fout`
  
  verbose && println(cmd)
  run(cmd)
  nothing
end


export app_cdo, cdo_grid, cdo_bilinear, cdo_apply
