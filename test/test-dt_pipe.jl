using DataFrames

df = datatable(; id=1:10, group=repeat([1, 2], 5), age=12)
mat = as_matrix(df)

@testset "cbind" begin
    mat = as_matrix(df)
    @test typeof(cbind(mat, mat, mat)) == Matrix{Int64}
    @test_nowarn cbind(id=1:10, df, df)
    @test_nowarn cbind(id=1:10, df, as_matrix(df))
    @test_nowarn cbind(id=1:10, as_matrix(df), df)
end

@testset "rbind" begin
    @test typeof(rbind(mat, mat, mat)) == Matrix{Int64}
    @test_nowarn rbind(df, mat)
    @test_nowarn rbind(mat, df)
    @test_nowarn rbind(df, mat, mat, df)
end

@testset "melt_list" begin
    probs = [0.90, 0.95, 0.99, 0.999, 0.9999]
    levs = factor(probs)

    d = DataFrame(x=1:40)
    names(d)

    d2 = cbind(d, prob=probs[1])
    @test names(d2) == ["x", "prob"]

    ## for data.frame melt_list
    res = []
    for i = 1:4
        push!(res, d)
    end

    df1 = melt_list(res, id=1:4)
    df2 = melt_list(res)
    # test for empty list
    push!(res, [])
    df3 = melt_list(res)
    @test names(df2) == ["x", "prob", "id", "I"]
end

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
