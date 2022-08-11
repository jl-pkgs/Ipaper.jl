# using Ipaper
# using Test
# @subset(dt, y == 2)

@testset "fwrite" begin
  df = DataFrame(A=1:3, B=4:6, C=7:9)
  fwrite(df, "a.csv")
  fwrite(df, "a.csv", append=true)

  df = fread("a.csv")
  @test nrow(df) == 6
  rm("a.csv")
end

# con = "x == 1 & y == 2 | z == 1"
# con_dt_transform(con; dname="df")
word = "[[:alnum:]_\\.\\[\\]]+"
pattern_lgl_left = "($word)( *)(?=[=<>≤≥\\!])" # logical operation
pattern_lgl_right = "(?<=[=<>≤≥])( *)($word)" # logical operation
pattern_op = r"([=<>≤≥\!]+)"

## Prepare for @subset
@testset "pattern key" begin
  # key = str_extract(x, pattern_lgl_left)
  @test str_extract_strip("x == 1", pattern_lgl_left) == "x"
  @test str_extract_strip("x != 1", pattern_lgl_left) == "x"
  @test str_extract_strip("x >= 1", pattern_lgl_left) == "x"
  @test str_extract_strip("x <= 1", pattern_lgl_left) == "x"
  @test str_extract_strip("x > 1", pattern_lgl_left) == "x"
  @test str_extract_strip("x < 1", pattern_lgl_left) == "x"
  # val = str_extract("x == 1", r"(?<=(==)|>=).*")
end

@testset "pattern val" begin
  # pattern_lgl_right = r"(?<===|\!=|>=|<=|>|≥|<|≤).*" # logical operation
  # key = str_extract(x, pattern_lgl_left)
  @test str_extract_strip("x == 1", pattern_lgl_right) == "1"
  @test str_extract_strip("x >= 1", pattern_lgl_right) == "1"
  @test str_extract_strip("x <= 1", pattern_lgl_right) == "1"
  @test str_extract_strip("x > 1", pattern_lgl_right) == "1"
  @test str_extract_strip("x < 1", pattern_lgl_right) == "1"
  @test str_extract_strip("x != 1", pattern_lgl_right) == "1"
end

@testset "pattern op" begin
  xs = [
    "x >= 1",
    "x == 1",
    "x != 1",
    "x > 1",
    "x < 1"]
  op = str_extract(xs, r"([=<>≤≥\!]+)")
  @test length(op) == length(xs)
end
