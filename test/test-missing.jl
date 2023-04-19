# using Ipaper
# using Test


@testset "missing" begin
  @test drop_missing([1, 2, missing], 0) == [1, 2, 0]
  @test drop_missing([1, 2, missing], -999) == [1, 2, -999]
  @test drop_missing([1, 2, 3], -999) == [1, 2, 3]

  @test isequal(to_missing([1, 2, 0]), [1, 2, missing])
  @test isequal(to_missing([1, 2, 3], 3), [1, 2, missing])
  # @test replace_value!([1, 2], 2, 3) == [1, 3]
end



@testset "to_missing" begin
  ## to_missing
  x = rand(Int32, 5, 5)
  x[1] = 999
  x[2] = 9999

  x_miss = to_missing(x, 999)
  x_miss2 = to_missing(x_miss, 9999)

  @test x_miss[1] === missing
  @test x_miss[2] == 9999
  @test x_miss2[1] === missing
  @test x_miss2[2] === missing

  ## to_missing!
  x = rand(Int32, 5, 5)
  x[1] = 999
  x[2] = 9999

  x_miss = to_missing(x, 999)
  x_miss2 = Ipaper.to_missing!(x_miss, 9999)

  @test x[1] == 999
  @test x[2] == 9999
  @test x_miss[1] === missing
  @test x_miss[2] === missing
  @test x_miss2[1] === missing
  @test x_miss2[2] === missing
end
