using Test
using rl_vac
using DataFrames
using Dates
using JSON3
using Random
using Distributions
using Debugger

@testset "compute_cost tests" begin
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)
    inventory_parameters = args["inventory_parameters"]
    time_interval_stencil = build_interval_stencil!(args)
    vaccine_coverage = get_vaccine_stock_coverage(args)
    vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
    args["state"].action = vaccination_rate
    args["state"].opt_policy = 0.5
    args["initial_condition"].action = vaccination_rate
    first_cost = compute_cost(args)

    for (j, t_j) in enumerate(time_interval_stencil[2:end-200])
        args["state"].time = t_j
        x_new = rhs_evaluation!(args)
    end

    j_cost = compute_cost(args)

    @test j_cost > first_cost
end