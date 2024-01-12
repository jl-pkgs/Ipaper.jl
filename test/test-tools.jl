@testset "tools" begin
  @test is_empty([])
  @test is_empty(nothing)
  @test !not_empty([])
  @test !not_empty(nothing)

  @test nth(1:10, 2) == 2
  @test seq_along(2:11) == 1:10

  @test r_range(1:10) == [1, 10]
end

@testset "cmd" begin
  @test_nowarn is_linux()
end

@testset "null | nothing" begin
  x = [1, 2, 3, nothing]
  @test which_isnull(x) == [4]
  @test which_notnull(x) == [1, 2, 3]
end

@testset "nan" begin
  x = [1, 2, 3, NaN]
  @test which_isnan(x) == [4]
  @test which_notnan(x) == [1, 2, 3]
end

@testset "abind" begin
  x = rand(4, 4, 1, 3)
  @test size(squeeze(x)) == (4, 4, 3)
  
  x = rand(4, 4, 1)
  y = [x, x, x]
  @test size(abind(y; increase=true)) == (4, 4, 1, 3)
  @test size(abind(y; increase=false)) == (4, 4, 3)
end
