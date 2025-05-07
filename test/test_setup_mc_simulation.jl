using Test
using DataFrames
using JSON
using rl_vac  # Assuming the module is named `rl_vac` and properly set up


@testset "set_up_mc_simulation Tests" begin
    df_monte_carlo, df_args_initial_condition, df_args_inventory_parameters, args = setup_mc_simulation()

    @test isa(df_monte_carlo, DataFrame)
    @test isempty(df_monte_carlo)

    @test isa(df_args_initial_condition, DataFrame)
    @test !isempty(df_args_initial_condition)
    @test "Conservative_Law" in names(df_args_initial_condition)

    @test isa(df_args_inventory_parameters, DataFrame)
    @test !isempty(df_args_inventory_parameters)
    @test "backup_inventory_level" in names(df_args_inventory_parameters)

    @test isa(args, Dict)
    @test "initial_condition" in keys(args)
    @test "inventory_parameters" in keys(args)
    @test "state" in keys(args)
end