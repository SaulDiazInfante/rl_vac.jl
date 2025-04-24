
@testset "save_solution_path tests" begin
    args = build_testing_parameters()
    sol = get_solution_path!(args)
    col_names = fieldnames(structState)
    expected_df = DataFrame(sol, collect(col_names))
    res = save_solution_path(sol)
    @test res == expected_df
end