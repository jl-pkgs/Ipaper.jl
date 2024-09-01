# using Ipaper
# using Test

@testset "agg" begin
  _size = (10, 10, 12)
  _size2 = (5, 5, 12)
  A = rand(Float32, _size)
  R = agg(A)
  @test size(R) == _size2
  @test eltype(R) == Float32
end


@testset "factor" begin
  probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
  levs = factor(probs)

  @test factor_value(levs) == probs
  
  n = Int(1e3)
  x = repeat([levs[1]], n)
  y = repeat([probs[1]], n)
  
  sizeof(x) < sizeof(y)
end


@testset "dir" begin
  files = dir(".", "\\.jl\$")
  @test length(files) > 0
end


@testset "check_file" begin
  check_file("a/b/c.tmp")
  @test isdir("a/b")
  check_file("a/b/c.tmp")

  check_dir("a/b")
  @test isdir("a/b")
  check_dir("a/b")
  rm("a", recursive=true)
end

@testset "duplicated" begin
  x = 1:1000 |> collect
  @test sum(duplicated(x)) == 0

  x = [1, 2, 1, 3]
  @test findall(duplicated(x)) == [3]
end

# using Test
@testset "stringr" begin
  x = "hello world!"
  @test gsub(x, "hello", "Hello") == "Hello world!"
  @test grepl(x, "!\$")
  @test grep(x, "!\$") == grep(x, "!\$")
end

@testset "r_summary" begin
  set_seed(1)
  x = rand(4, 4)
  x[1] = NaN

  obj_size(x)
  r_summary(x)
  @test true
end

@testset "weighted_mean" begin
  x = 1:4 |> collect
  w = [1, 1, 0.5, 0.5]
  @test weighted_mean(x, w) ≈ 2.166666666
  @test weighted_sum(x, w) ≈ 6.5
end
