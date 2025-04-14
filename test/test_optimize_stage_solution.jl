args = build_testing_parameters()
initial_condition = args["initial_condition"]
numeric_solver_par = args["numeric_solver_parameters"]
inventory_parameters = args["inventory_parameters"]

N_grid_size = numeric_solver_par.N_grid_size
operational_fractions = inventory_parameters.operational_stock_levels
state_dim = length(fieldnames(structState))

@testset "optimize_stage_solution! tests" begin

    opt_solution = optimize_stage_solution!(args)
    @test size(opt_solution) == (
        N_grid_size,
        length(
            fieldnames(structState)
        )
    )

    random_policy = rand(operational_fractions)
    copy_args = copy(args)
    copy_args["initial_condition"].opt_policy = random_policy
    copy_args["state"] = copy_args["initial_condition"]

    solution_with_random_policy = get_stage_solution!(copy_args)
    optimal_cost = opt_solution[end, 12]
    cost_random_policy = solution_with_random_policy[end, 12]
    @test (optimal_cost <= cost_random_policy)
end
