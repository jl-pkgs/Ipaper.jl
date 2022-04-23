# using Ipaper

@testset "datatable" begin
  x = 1
  y = 2
  d = datatable(; x, y=2)

  @test typeof(d) == DataFrame
end
