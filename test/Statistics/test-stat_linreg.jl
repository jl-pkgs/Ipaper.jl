@testset "linreg" begin
  
  x = collect(1.0:10)
  y = collect(1.0:10)
  y[1] = NaN
  
  @test linreg(y, x; na_rm=true)[2] ≈ 1.0
  @test linreg(y; na_rm=true)[2] ≈ 1.0
  
  @test linreg_simple(y, x; na_rm=true)[2] ≈ 1.0
  @test linreg_simple(y; na_rm=true)[2] ≈ 1.0
end
