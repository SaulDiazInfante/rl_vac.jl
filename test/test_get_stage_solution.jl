using Test
using rl_vac
using DataFrames
using Dates
using JSON3
using Random
using Distributions
using Debugger

args = build_testing_parameters()

@testset "get_stage_solution! tests" begin
    initial_condition = get_struct_values(args["initial_condition"])
    state_dim = length(fieldnames(structState))
    numeric_solver_par = args["numeric_solver_parameters"]
    N_grid_size = numeric_solver_par.N_grid_size

    sol = get_stage_solution!(args)

    @test size(sol) == (N_grid_size, state_dim)
    @test sol[1, :] == initial_condition
    @test sol[end, :] == get_struct_values(args["state"])
end
