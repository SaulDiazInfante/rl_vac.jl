using rl_vac
using Test
using JSON3
using DataFrames

args = build_testing_parameters()
@testset "save_inventory_parameters_to_json tests" begin
    inventory_params = args["inventory_parameters"]
    temp_filename = "test_inventory_parameters.json"

    df = save_inventory_parameters_to_json(inventory_params, temp_filename)

    @test isfile(temp_filename)
    json_data = JSON3.read(temp_filename, Dict)
    @test json_data["backup_inventory_level"][1] == inventory_params.backup_inventory_level

    @test json_data["t_delivery"] == inventory_params.t_delivery
    @test json_data["delivery_size_k"] == inventory_params.delivery_size_k

    @test json_data["yll_weight"][1] == inventory_params.yll_weight
    @test json_data["yld_weight"][1] == inventory_params.yld_weight
    @test json_data["stock_cost_weight"][1] == inventory_params.stock_cost_weight
    @test json_data["campaign_cost_weight"][1] == inventory_params.campaign_cost_weight

    @test filter(!isnothing, json_data["operational_stock_levels"]) ==
          inventory_params.operational_stock_levels
    @test json_data["backup_inventory_level"][1] == inventory_params.backup_inventory_level
    rm(temp_filename, force=true)
end