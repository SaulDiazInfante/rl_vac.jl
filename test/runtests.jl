using Test
using rl_vac
using DataFrames
using Dates
using JSON3
using Random
using Distributions

@testset "rl_vac Tests" begin
    include("test_build_testing_parameters.jl")
    include("test_compute_cost.jl")
    include("test_compute_nsfd_iteration.jl")
    include("test_compute_mr_ou_temp_loss.jl")
    include("test_get_vaccine_stock_coverage.jl")
    include("test_build_interval_stencil.jl")
    include("test_get_stencil_projection.jl")
    include("test_tag_file.jl")
    include("test_get_max_vaccination_rate.jl")
    include("test_get_vaccine_stock_coverage.jl")
    include("test_json_to_struct.jl")
    include("test_get_stochastic_perturbation.jl")
    include("test_get_struct_values.jl")
    include("test_rhs_evaluation.jl")
    include("test_get_stage_solution.jl")
    include("test_optimize_stage_solution.jl")
end