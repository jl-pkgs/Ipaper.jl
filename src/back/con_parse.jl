function con_parse(x::AbstractString)
  word = "[[:alnum:]_\\.\\[\\]\"]+"
  pattern_lgl_left = "($word)( *)(?=[=<>≤≥\\!])" # logical operation
  pattern_lgl_right = "(?<=[=<>≤≥])( *)($word)" # logical operation
  pattern_op = r"([=<>≤≥\!]+)"

  k = str_extract_strip(x, pattern_lgl_left)
  v = str_extract_strip(x, pattern_lgl_right)
  op = str_extract_strip(x, pattern_op)
  k, v, op
end

function _con_dt_transform(dname::AbstractString, con::AbstractString)
  k, v, op = con_parse(con)
  k = "$dname.$k"
  op = ".$op"
  "($k $op $v)"
end

function _con_dt_transform(dname::AbstractString, con::Vector{<:AbstractString})
  map(x -> _con_dt_transform(dname, x), con)
end

function con_dt_transform(con::AbstractString; dname="d")
  cons_and = split(con, "&")
  cons_or = cons_and |> x -> split.(x, "|")

  con2 = map(con_or -> begin
      _con_dt_transform(dname, con_or) |> x -> join(x, " .| ")
    end, cons_or) |> x -> join(x, " .& ")
  "$dname[$con2, :]"
end


export con_split, con_parse, con_dt_transform,
  paste
