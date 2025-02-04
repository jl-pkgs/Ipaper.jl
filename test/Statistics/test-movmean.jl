@testset "movstd" begin
  @test movstd([1, 2, 2]) == [0.7071067811865476, 0.5773502691896255, 0.0]
  @test movstd([1, 3, 2]; skip_centre=true)[2] == 0.7071067811865476
end


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

  # Moving average: 1D, 2side windows
  @test movmean(1:10, (1, 1)) == [1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 9.5]
  @test movmean(1:10, (1, 1); skip_centre=true) == [2.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 9.0]
  @test movmean(1:10, (1, 2)) == [2.0, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.0, 9.5]
end

@testset "weighted_movmean" begin
  r = weighted_movmean([1, 3, 5], [0.1, 1, 0.2])
  @test length(r) == 3
end

@testset "weighted_nansum" begin
  x = [1.0, NaN, 3]
  # A = reshape(x, 1, 1, 3)
  @test weighted_nansum([1.0, 2, 3], [1, 1, 1]) == 6.0
  @test weighted_nansum(x, [1, 1, 1]) == 4.0
  # @test weighted_nansum(A, [1, 1, 1])[1] == 4.0
end

@testset "weighted_nansum" begin
  x = [1.0, NaN, 3]
  A = reshape(x, 1, 1, 3)
  @test weighted_nanmean([1.0, 2, 3], [1, 1, 1]) == 2.0
  @test weighted_nanmean(x, [1, 1, 1]) == 2.0
  # weighted_nanmean(A, [1, 1, 1])[1] == 4.0
end
