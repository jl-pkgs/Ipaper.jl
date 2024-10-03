using Distributions
using Ipaper
using Test

@testset "slope_fun" begin
  x = [4.81, 4.17, 4.41, 3.59, 5.87, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69]

  t_mk = slope_mk(x)
  t_lm = slope_p(x)

  @test t_mk == [0.03500000000000003, 0.6962153512437399]
  @test t_lm == [0.038909090909090956, 0.6506414661298834]

  t_mk = slope_mk(x; nmin=length(x) + 1)
  @test isnan.(t_mk) == [true, true] # [NaN, NaN]
end
