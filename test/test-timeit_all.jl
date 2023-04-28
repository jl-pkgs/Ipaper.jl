# include("test/main_pkgs.jl")
# include("../src/timeit_all.jl")
# using Ipaper

@testset "@timeit_all" begin
  @timeit_all function foo(n)
    for i = 1:n
      begin
        A = randn(100, 100, 20)
        m = maximum(A)
      end
      if i < 10
        Am = mapslices(sum, A; dims=2)
        B = A[:, :, 5]
        Bsort = mapslices(B; dims=1) do col
          sort(col)
        end
      elseif i < 15
        sleep(0.01)
      else
        sleep(0.02)
      end
      let j
        j = i
        while j < 5
          b = rand(100)
          C = B .* b
          j += 1
        end
      end
    end
    sleep(0.5)
  end

  reset_timer!(to)
  foo(20)
  to
  show(to, sortby=:firstexec)
end
