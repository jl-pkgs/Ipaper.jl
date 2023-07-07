using Test

@testset "r_in tests" begin
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
