using Test
using Ipaper


@testset "list object" begin
  x = list(; a=1, b=1:4)
  x.a = 2

  x2 = append(x, list(; c=1))
  @test length(x2) == 3
  @test names(x2) == [:a, :b, :c]
  @test x == list(; a=2, b=1:4)
  
  @test list([:x]) == list(["x"])
  @test list([:x], 1) == list(["x"], 1)
end
