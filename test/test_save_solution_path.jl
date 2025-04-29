
@testset "save_solution_path tests" begin
    args = build_testing_parameters()
    sol = get_solution_path!(args)
    col_names = fieldnames(structState)
    expected_df = DataFrame(sol, collect(col_names))
    res = save_solution_path(sol)
    @test res == expected_df
    data_dir = joinpath(
        dirname(@__DIR__),
        "data/"
    )
    saved_files = readdir(data_dir)
    @test any(endswith(".csv"), saved_files)
end