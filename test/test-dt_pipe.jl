using DataFrames

df = datatable(; id=1:10, group=repeat([1, 2], 5), age=12)
# @pipe d |> groupby(:y)
# `>(6)` has to in this format
@pipe df |>
      dropmissing |>
      filter(:id => >(6), _) |>
      groupby(:group) |>
      combine(:age => sum)

@pipe df |>
      dropmissing |>
      filter(:id => >(6), _)


@testset "@subset" begin
  x = 1:2
  y = 2
  dt = datatable(; x, y=[2, 3], z=[1, 3])

  @test typeof(dt) == DataFrame
  @test @subset(dt, y == 2) |> nrow == 1
  @test @subset(dt, y == 1) |> nrow == 0
  @test @subset(dt, y == 2 & z == 1) |> nrow == 1

  # works for global variable
  y0 = 2
  @test @pipe(dt |> @subset(y == 2, true)) == @pipe(dt |> @subset(y == y0, true))
end
## add GOF function
