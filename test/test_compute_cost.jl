mutable struct MockState
    E::Float64
    K_stock_t::Float64
    X_vac::Float64
end

mutable struct MockParameters
    p::Float64
    delta_e::Float64
    theta::Float64
    alpha_s::Float64
end

mutable struct MockInventoryParameters
    yll_weight::Vector{Float64}
    yld_weight::Vector{Float64}
    stock_cost_weight::Vector{Float64}
    campaign_cost_weight::Vector{Float64}
end

# Test cases for compute_cost
@testset "compute_cost tests" begin
    initial_condition = MockState(100.0, 50.0, 20.0)
    state = MockState(120.0, 60.0, 25.0)
    model_parameters = MockParameters(0.5, 1.2, 0.8, 1.5)
    inventory_parameters = MockInventoryParameters([2.0], [1.5], [3.0], [4.0])

    args = Dict(
        "initial_condition" => initial_condition,
        "state" => state,
        "model_parameters" => model_parameters,
        "inventory_parameters" => inventory_parameters
    )

    # Expected cost calculation
    yll = 2.0 * 0.5 * 1.2 * (120.0 - 100.0)
    yld = 1.5 * 0.8 * 1.5 * (120.0 - 100.0)
    stock_cost = 3.0 * (60.0 - 50.0)
    campaign_cost = 4.0 * (25.0 - 20.0)
    expected_cost = yll + yld + stock_cost + campaign_cost

    @test compute_cost(args) ≈ expected_cost
end