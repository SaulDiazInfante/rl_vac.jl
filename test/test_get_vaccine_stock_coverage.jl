
args = build_testing_parameters()
process_first_inventory_reorder_point!(args)
# Test cases
@testset "get_vaccine_stock_coverage tests" begin
    inventory_parameters = args["inventory_parameters"]
    pop_size = args["model_parameters"].N
    first_delivery_size = inventory_parameters.delivery_size_k[1]
    backup_inventory_size = inventory_parameters.backup_inventory_level
    result = get_vaccine_stock_coverage(args)

    @test result * pop_size == (first_delivery_size - backup_inventory_size)
    args["state"].K_stock_t = 1950 / pop_size
    @test get_vaccine_stock_coverage(args) == 0.0
end