@testset "movmean" begin
  dates = make_date(2010, 1, 1):Day(1):make_date(2010, 12, 31)
  n = 100
  x = rand(n, n, 365)

  function test_movmean(x, halfwin=2)
    r = movmean(x, halfwin)
    @test r[1, 1, :] == movmean(x[1, 1, :], halfwin)
    @test r[n, n, :] == movmean(x[n, n, :], halfwin)
  end
  test_movmean(x, 1)
  test_movmean(x, 2)
  test_movmean(x, 10)

  @test movmean([1, 3, 5], 1) == [2, 3, 4.0]
end


@testset "weighted_movmean" begin
  r = weighted_movmean([1, 3, 5], [0.1, 1, 0.2])
  @test length(r) == 3
end

@testset "weighted_nansum" begin
  x = [1.0, NaN, 3]
  A = reshape(x, 1, 1, 3)
  weighted_nansum([1.0, 2, 3], [1, 1, 1]) == 6.0
  weighted_nansum(x, [1, 1, 1]) == 4.0
  weighted_nansum(A, [1, 1, 1])[1] == 4.0
end
