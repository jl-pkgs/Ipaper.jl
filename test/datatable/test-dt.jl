using Ipaper
using Test
# @subset(dt, y == 2)

@testset "dt_merge" begin
  d1 = DataFrame(A=1:3, B=4:6, C=7:9)
  d2 = DataFrame(A=1:3, B=4:6, D=7:9)

  r1 = dt_merge(d1, d2, by = [:A])
  r2 = dt_merge(d1, d2, by = ["A"])
  @test r1 == r2
  r3 = dt_merge(d1, d2, by = :A, suffixes=["_tas", ".rh"])
  r4 = dt_merge(d1, d2, by = "A", suffixes=["_tas", ".rh"])
  @test length(r4[:, "B.rh"]) == 3
end

@testset "fwrite" begin
  df = DataFrame(A=1:3, B=4:6, C=7:9)
  fwrite(df, "a.csv")
  fwrite(df, "a.csv", append=true)

  df = fread("a.csv")
  @test nrow(df) == 6
  rm("a.csv")
end
