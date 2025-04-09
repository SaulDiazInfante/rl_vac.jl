using Test
using .rl_vac
@testset "compute_nsfd_iteration!" begin
    initial_condition_path = joinpath(
        @__DIR__,
        "../data/initial_condition.json"
    )
    model_parameters_path = joinpath(
        @__DIR__, "../data/model_parameters.json"
    )
    numeric_solver_parameters_path = joinpath(
        @__DIR__,
        "../data/numeric_solver_parameters.json"
    )
    inventory_parameters_path = joinpath(
        @__DIR__,
        "../data/inventory_parameters.json"
    )
    initial_condition = json_to_struct(structState, initial_condition_path)
    current_state = json_to_struct(structState, initial_condition_path)
    model_par = json_to_struct(structModelParameters, model_parameters_path)
    numeric_solver_par = json_to_struct(
        structNumericSolverParameters,
        numeric_solver_parameters_path
    )
    inventory_par = json_to_struct(
        structInventoryParameters, inventory_parameters_path
    )

    args = Dict(
        "initial_condition" => initial_condition,
        "state" => current_state,
        "model_parameters" => model_par,
        "numeric_solver_parameters" => numeric_solver_par,
        "inventory_parameters" => inventory_par
    )

    result = compute_nsfd_iteration!(args)

    # Validate results
    @test length(result) == 18
    @test isapprox(sum(result[2:8]), 1.0; atol=1e-12)
    @test args["state"].time == result[1]
    @test args["state"].S == result[2]
    @test args["state"].E == result[3]
    @test args["state"].I_S == result[4]
    @test args["state"].I_A == result[5]
    @test args["state"].R == result[6]
    @test args["state"].D == result[7]
    @test args["state"].V == result[8]
end