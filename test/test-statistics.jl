@testset "Quantile" begin
  n = 20
  @test size(Quantile(rand(n, n, 30); dims = 3)) == (n, n, 5)
  @test size(Quantile(rand(n, n, 30); dims = 2)) == (n, 5, 30)
  @test size(Quantile(rand(n, n, 30); dims = 1)) == (5, 20, 30)

  # Test for missing values
  @test Quantile([1, 2, missing, 4, 5, 10]) |> size == (5, )
end


using Ipaper
x = [missing, missing]
isequal(quantile(skipmissing(x), 0.1), missing)
isequal(quantile(skipmissing(x), [0.1, 0.2]), [missing, missing])

x = [missing, missing, 1, 2]
quantile(skipmissing(x), 0.1)
quantile(skipmissing(x), [0.1, 0.2])


x = rand(4, 4) |> to_missing
x[1:2, :] .= missing
[Quantile(x[i, :], [0.1, 0.2]) for i = 1:4]


# Quantile(x, [0.1, 0.2]; dims = 1)
Quantile(x, [0.1, 0.2]; dims = 2)


# mapslices(x -> typeof(x), x, dims=1)

using Statistics


