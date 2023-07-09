using Test

@testset "r_in" begin
  # Test case 1: x is in y
  x = [1, 2, 3]
  y = [3, 2, 1]
  @test r_in(x, y) == [true, true, true]

  # Test case 2: x is not in y
  x = [4, 5, 6]
  y = [1, 2, 3]
  @test r_in(x, y) == [false, false, false]

  # Test case 3: x is partially in y
  x = [1, 2, 3]
  y = [2, 3, 4]
  @test r_in(x, y) == [false, true, true]

  # Test case 4: x and y are empty
  x = []
  y = []
  @test r_in(x, y) == BitVector([])

  # Test case 5: x is empty
  x = []
  y = [1, 2, 3]
  @test r_in(x, y) == BitVector([])

  # # Test case 6: y is empty
  # x = [1, 2, 3]
  # y = []
  # @test r_in(x, y) == BitVector([])
end

# add test for r_chunk
@testset "r_chunk" begin
  @test r_chunk(10, 3) == [1:3, 4:6, 7:10]
  @test r_chunk(10, 4) == [1:2, 3:4, 5:6, 7:10]
  @test r_chunk(1:10, 4) == r_chunk(10, 4)
end


@testset "r_summary" begin
  @test r_summary(1:10) === nothing
  @test r_summary(rand(2, 2)) === nothing
end

@testset "duplicated" begin
  @test duplicated([1, 2, 3, 4, 1]) == [0, 0, 0, 0, 1]
  @test duplicated([1, 2, 1, 1, 1]) == [0, 0, 1, 1, 1]
end

@testset "match2" begin
  value, I_x, I_y = match2([1, 2, 3, 4], [3, 4, 5])
  @test I_x == [3, 4]
  @test I_y == [1, 2]
end
