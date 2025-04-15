using Test
using rl_vac
using Debugger
@testset "build_testing_parameters" begin
    mock_data_dir = joinpath(@__DIR__, "../data")
    mkpath(mock_data_dir)

    result = build_testing_parameters()


    # Validate the results
    @test typeof(result["initial_condition"]) == structState
    @test typeof(result["state"]) == structState
    @test typeof(result["model_parameters"]) == structModelParameters
    @test typeof(result["numeric_solver_parameters"]) == structNumericSolverParameters

    @test typeof(result["inventory_parameters"]) == structInventoryParameters
end