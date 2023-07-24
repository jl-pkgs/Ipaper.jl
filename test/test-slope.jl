using Distributions
using Ipaper
using Test

@testset "slope_fun" begin
  x = [4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69]
  t_mk = slope_mk(x)
  t_lm = slope_p(x)

  @test t_mk == (slope=0.040000000000000036, pvalue=0.7205147871362552)
  @test t_lm == (slope=0.04636363636363642, pvalue=0.6249862523021623)
end
