args = build_testing_parameters()
process_first_inventory_reorder_point!(args)
@testset "get_stage_solution! tests" begin
    initial_condition = args["initial_condition"]
    initial_condition_values = get_struct_values(initial_condition)
    state_dim = length(fieldnames(structState))
    numeric_solver_par = args["numeric_solver_parameters"]
    N_grid_size = numeric_solver_par.N_grid_size
    sol = get_stage_solution!(args)
    # Debugger.@enter get_stage_solution!(args)
    @test size(sol) == (N_grid_size, state_dim)
    @test sol[1, :] == get_struct_values(initial_condition)
    @test sol[end, :] == get_struct_values(args["state"])
end


function test_stage_solution()
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)
    state = copy(args["state"])
    model_parameters = copy(args["model_parameters"])
    numeric_solver_parameters = copy(args["numeric_solver_parameters"])
    inventory_parameters = copy(args["inventory_parameters"])

    N_grid_size = numeric_solver_parameters.N_grid_size
    pop_size = model_parameters.N
    list_solution = Matrix{Real}[]
    df_solution = DataFrame()
    vaccine_coverage = get_vaccine_stock_coverage(args)
    vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
    args["state"].action = vaccination_rate
    args["initial_condition"].action = vaccination_rate
    initial_condition = copy(args["initial_condition"])
    operational_fractions = inventory_parameters.operational_stock_levels
    state_dim = length(fieldnames(structState))

    solution_t = zeros(Real, N_grid_size, state_dim)
    opt_solution = zeros(Real, N_grid_size, state_dim)
    opt_cost = Inf
    copy_args = copy(args)
    opt_args = copy(copy_args)
    rho_k = 0.7
    #for rho_k in operational_fractions
    initial_condition.opt_policy = rho_k
    copy_args["initial_condition"] = copy(initial_condition)
    copy_args["state"] = copy(initial_condition)
    solution_t = get_stage_solution!(copy_args)
    cost = copy_args["state"].X_0_mayer
    if cost <= opt_cost
        opt_cost = cost
        opt_solution = solution_t
        opt_args = copy(copy_args)
    end
    #end
    args["state"] = opt_args["state"]
end

Debugger.@enter test_stage_solution()