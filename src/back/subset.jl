
macro subset(d, con, verbose = false)
  # @show d, typeof(d)
  dname = string(d)
  con = string(con)
  # @show dname, con

  expr = con_dt_transform(con; dname=dname)
  verbose && @show expr
  esc(Meta.parse(expr))
end

export @subset
