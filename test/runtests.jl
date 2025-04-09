using Test
using rl_vac

@testset "rl_vac Tests" begin
    include("test_compute_cost.jl")
    include("test_compute_nsfd_iteration.jl")
    include("test_rhs_evaluation.jl")
end