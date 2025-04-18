using Test
using rl_vac
using DataFrames, CSV
using Debugger


args = build_testing_parameters()
process_first_inventory_reorder_point!(args)

model_parameters = copy(args["model_parameters"])
numeric_solver_parameters = copy(args["numeric_solver_parameters"])
inventory_parameters = copy(args["inventory_parameters"])

stage_solution = optimize_stage_solution!(args)


# Test cases
@testset "process_inventory_reorder_point!" begin
    process_inventory_reorder_point!(args)
    initial_condition = args["initial_condition"]
    state = args["state"]
    numeric_solver_parameters = args["numeric_solver_parameters"]
    inventory_parameters = args["inventory_parameters"]


    @test initial_condition.K_stock_t == state.K_stock_t
    @test state.K_stock_t >= (
        inventory_parameters.delivery_size_k[1] / model_parameters.N
    )

    @test initial_condition.time == inventory_parameters.t_delivery[2]
    @test args["state"].time = initial_condition.time
end
