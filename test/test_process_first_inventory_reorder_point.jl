args = build_testing_parameters()

@testset "process_first_inventory_reorder_point!" begin

    initial_condition = copy(args["initial_condition"])
    state = copy(args["state"])
    model_parameters = copy(args["model_parameters"])
    numeric_solver_parameters = copy(args["numeric_solver_parameters"])
    inventory_parameters = copy(args["inventory_parameters"])


    expected_K_stock_t = inventory_parameters.delivery_size_k[1] / model_parameters.N
    expected_current_stage_interval = [0.0, 80.0]
    process_first_inventory_reorder_point!(args)

    @test args["state"].K_stock_t ≈ expected_K_stock_t
    @test args["numeric_solver_parameters"].current_stage_interval == expected_current_stage_interval
end


