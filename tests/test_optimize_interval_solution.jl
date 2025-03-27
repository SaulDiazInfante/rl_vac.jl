using Test

# Mock function for `get_interval_solution!`
function get_interval_solution!(time_interval, x_0, policy, a_t, k_0, parameters)
    # Mock behavior: return a matrix where the last column contains costs
    # The cost is inversely proportional to the policy value for testing purposes
    cost = 1 / policy
    return [zeros(10, 11); hcat(zeros(1, 10), cost)]
end

# Mock parameters
struct MockParameters
    operational_stock_levels::Vector{Float64}
end

# Test cases for `optimize_interval_solution`
@testset "optimize_interval_solution tests" begin
    # Test 1: Basic functionality
    time_interval = 1:10
    x_0 = [0.0]
    a_t = [0.0]
    k_0 = 0.0
    parameters = MockParameters([0.1, 0.2, 0.5, 1.0])  # Operational stock levels

    opt_solution = optimize_interval_solution(time_interval, x_0, a_t, k_0, parameters)

    @test size(opt_solution) == (11, 11)  # Check the size of the solution matrix
    @test opt_solution[end, 11] == 1.0  # The minimum cost corresponds to policy 1.0

    # Test 2: Single operational stock level
    parameters = MockParameters([0.5])
    opt_solution = optimize_interval_solution(time_interval, x_0, a_t, k_0, parameters)

    @test size(opt_solution) == (11, 11)
    @test opt_solution[end, 11] == 2.0  # Cost for policy 0.5 is 1 / 0.5 = 2.0

    # Test 3: Edge case with no operational stock levels
    parameters = MockParameters([])
    @test_throws BoundsError optimize_interval_solution(time_interval, x_0, a_t, k_0, parameters)
end