using TimerOutputs
to = TimerOutput()


function map_kw(fun, x; kw...)
  fun2(x) = fun(x; kw...)
  map(fun2, x)
end

# modified by reference
mutable struct ExprOption
  line::Integer
end


macro timeit_all(ex)
  # dump(ex)
  ex = tidy_expr(ex; option=ExprOption(1))
  # @show esc(ex)
  return esc(ex)
end


function tidy_expr(expr::Expr; option::ExprOption)
  # printstyled("=============================\n", color=:red, bold=true, underline=false)
  # dump(expr)
  TYPES2 = [:function, :for, :if, :let, :while]
  TYPES1 = [:block, :do]

  HEAD = expr.head
  line = "L$(option.line)"
  
  if HEAD in TYPES2
    expr.args[2].args = map_kw(tidy_expr, expr.args[2].args; option)
    label = "$line: $(string(HEAD))"
  else
    if HEAD in TYPES1
    # if has_expr_children(expr)
      expr.args = map_kw(tidy_expr, expr.args; option)
      label = "$line: $(string(HEAD))"
    else
      label = "$line: $(string(expr))"
    end
    length(label) >= 30 && (label = "$(label[1:30]) ...")
  end

  if HEAD != :function
    expr = :(@timeit to $label $expr)
  end
  
  expr
end

function tidy_expr(expr::LineNumberNode; option::ExprOption)
  # dump(expr)
  # @show expr.file
  option.line = expr.line
  expr
end

function tidy_expr(expr::Symbol; option::ExprOption)
  expr
end


function has_expr_children(expr)
  any(map(x -> typeof(x) == Expr, expr.args))
  # hasfield(expr, "args")
end

export @timeit_all, to, map_kw
