# using Ipaper
# using Test


@testset "missing" begin
  @test drop_missing([1, 2, missing]) == [1, 2, 0]
  @test drop_missing([1, 2, missing], -999) == [1, 2, -999]
  @test drop_missing([1, 2, 3], -999) == [1, 2, 3]

  @test isequal(to_missing([1, 2, 0]), [1, 2, missing])
  @test isequal(to_missing([1, 2, 3], 3), [1, 2, missing])

  @test replace_value!([1, 2], 2, 3) == [1, 3]
end
