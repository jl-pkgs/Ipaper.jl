@testset "tools" begin
  @test is_empty([])
  @test is_empty(nothing)
  @test !not_empty([])
  @test !not_empty(nothing)

  @test nth(1:10, 2) == 2
  @test seq_along(2:11) == 1:10

  @test r_range(1:10) == [1, 10]
end
