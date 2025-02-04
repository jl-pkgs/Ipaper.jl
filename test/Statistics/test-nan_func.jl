using Ipaper, Test

@testset "weighted nanmean and nansum" begin
  @test nansum([1, 2, 3, NaN]) == 6.0
  @test nanmean([1, 2, 3, NaN]) == 2.0

  x = [1.0, NaN, 3]
  @test weighted_nansum([1.0, 2, 3], [1, 1, 1]) == 6.0
  @test weighted_nansum(x, [1, 1, 1]) == 4.0

  @test weighted_nanmean([1.0, 2, 3], [1, 1, 1]) == 2.0
  @test weighted_nanmean(x, [1, 1, 1]) == 2.0
  # A = reshape(x, 1, 1, 3)
  # @test weighted_nansum(A, [1, 1, 1])[1] == 4.0
end
