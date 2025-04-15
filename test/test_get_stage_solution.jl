args = build_testing_parameters()

@testset "get_stage_solution! tests" begin
    initial_condition = args["initial_condition"]
    initial_condition_values = get_struct_values(initial_condition)
    state_dim = length(fieldnames(structState))
    numeric_solver_par = args["numeric_solver_parameters"]
    N_grid_size = numeric_solver_par.N_grid_size

    interval_stencil = build_interval_stencil!(args)
    sol = get_stage_solution!(args)

    @test size(sol) == (N_grid_size, state_dim)
    @test sol[1, :] == initial_condition
    @test sol[end, :] == get_struct_values(args["state"])
end
