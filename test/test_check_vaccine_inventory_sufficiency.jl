using Test
using rl_vac
@testset "check_vaccine_inventory_sufficiency tests" begin
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)
    current_state = copy(args["state"])
    inventory_par = copy(args["inventory_parameters"])
    stage_initial_condition = copy(args["initial_condition"])
    mod_par = copy(args["model_parameters"])

    x_new = compute_nsfd_iteration!(args)
    new_state = args["state"]
    result = check_vaccine_inventory_sufficiency(args, new_state)
    @test result == true
    args = build_testing_parameters()
    args["state"].K_stock_t
    result = check_vaccine_inventory_sufficiency(args, new_state)
    @test result == false
end
