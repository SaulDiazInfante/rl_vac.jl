@testset "adapt_vaccination_rate_to_inventory!" begin
    current_args = build_testing_parameters()
    process_first_inventory_reorder_point!(current_args)

    current_state = current_args["state"]
    mod_par = current_args["model_parameters"]

    x_new = adapt_vaccination_rate_to_inventory!(current_args)
    updated_args = copy(current_args)

    @test updated_args["state"].action >= 0.0
    @test updated_args["model_parameters"].psi_v ==
          updated_args["state"].action
    @test updated_args["state"].K_stock_t * POP_SIZE >= 2000
    @test updated_args["state"].time >= 0.0
end
