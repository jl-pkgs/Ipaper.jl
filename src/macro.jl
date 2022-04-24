
macro subset(d, con, verbose = false)
  dname = string(d)
  con = string(con)
  expr = con_dt_transform(con; dname=dname)
  verbose && @show expr
  esc(Meta.parse(expr))
end

export @subset
