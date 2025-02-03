using Ipaper, Test

@testset "approx" begin
  set_seed(1)
  x = rand(5)
  y = rand(5)
  xout = 0:0.2:1
  yout = approx(x, y, xout; rule=2)
  @test yout == [
    0.19280811624587546
    0.4578365338937813
    0.7520040593947978
    0.6803853758191772
    0.4936193712530478
    0.16771210647092682
  ]

  y = [1, 2, 3.]
  # DateTime
  t = [
    DateTime(2019, 1, 3),
    DateTime(2019, 1, 5),
    DateTime(2019, 1, 7),
  ]
  tout = [
    DateTime(2019, 1, 2),
    DateTime(2019, 1, 3),
    DateTime(2019, 1, 4),
    DateTime(2019, 1, 8),
  ]
  yout = approx(t, y, tout; rule=2)
  @test yout == [1.0, 1.0, 1.5, 3.0]

  # Date
  t = [
    Date(2019, 1, 3),
    Date(2019, 1, 5),
    Date(2019, 1, 7),
  ]
  tout = [
    Date(2019, 1, 2),
    Date(2019, 1, 3),
    Date(2019, 1, 4),
    Date(2019, 1, 8),
  ]
  yout = approx(t, y, tout; rule=2)
  @test yout == [1.0, 1.0, 1.5, 3.0]
end

# using RCall

# begin
#   R"""
#   n = 20
#   x = rnorm(n)
#   y = rnorm(n)
#   xout = runif(n, -1, 21)
#   xout = runif(n, -5, 5)
#   yout = approx(x, y, xout, rule=2)$y
#   """

#   x = R"x" |> rcopy
#   y = R"y" |> rcopy
#   xout = R"xout" |> rcopy
#   y_r = R"yout" |> rcopy
#   y_jl = approx(x, y, xout; rule=2)
#   diff = y_jl - y_r
#   @test maximum(abs.(diff)) <= 1e-8
# end
