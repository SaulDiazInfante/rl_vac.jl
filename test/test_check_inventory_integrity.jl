@testset "check_inventory_integrity tests" begin
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)
    result = check_inventory_integrity(args)
    @test result == true

    args["state"].Conservative_Law = 0.9
    args["state"].K_stock_t = 100.0
    args["state"].X_vac = 0.0
    args["state"].stock_loss = 0.0
    result = check_inventory_integrity(args)
    @test result == false

    args = build_testing_parameters()
    x_new = compute_nsfd_iteration!(args)
    result = check_inventory_integrity(args)
    @test result == true
end
