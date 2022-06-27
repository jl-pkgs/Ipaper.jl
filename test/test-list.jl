using Test
using Ipaper


@testset "list object" begin
  x = list(; a=1, b=1:4)
  x.a = 2

  @test x == list(; a=2, b=1:4)
end
