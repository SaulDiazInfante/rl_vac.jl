using Test
include("compute_nsfd_iteration.jl")  # Assuming the function is defined in this file
# Mock structures to simulate the input arguments

Base.@kwdef struct MockParameters
    t_delivery::Vector{Float64}
    X_vac_interval::Vector{Float64}
    omega_v::Vector{Float64}
    p::Vector{Float64}
    alpha_a::Vector{Float64}
    alpha_s::Vector{Float64}
    theta::Vector{Float64}
    delta_e::Vector{Float64}
    delta_r::Vector{Float64}
    mu::Vector{Float64}
    epsilon::Vector{Float64}
    beta_s::Vector{Float64}
    beta_a::Vector{Float64}
    N_grid_size::Vector{Int}
    h::Float64
    theta_T::Float64
    mu_T::Float64
    sigma_T::Float64
    kappa::Float64
    N_refinement_steps::Int
    N_radom_variables_per_step::Int
    seed::Int
    debug::Bool
end

Base.@kwdef struct MockState
    S::Vector{Float64}
    E::Vector{Float64}
    I_S::Vector{Float64}
    I_A::Vector{Float64}
    R::Vector{Float64}
    D::Vector{Float64}
    V::Vector{Float64}
    X_vac::Vector{Float64}
    X_0_mayer::Vector{Float64}
    K_stock_t::Vector{Float64}
    time::Vector{Float64}
    T::Vector{Float64}
end

Base.@kwdef struct MockArgs
    t::Float64
    x::MockState
    parameters::MockParameters
    opt_policy::Float64
    action_t::Float64
end

# Mock functions
function get_stencil_projection(time, parameters)
    return min(Int(floor(time)), length(parameters.t_delivery) - 1)
end

function compute_mr_ou_temp_loss(; kwargs...)
    return Dict(:loss_j => 0.1, :temp_j => 0.2)
end

function compute_cost(x, parameters)
    return 0.05
end



# Test cases
@testset "compute_nsfd_iteration! tests" begin
    # Define mock parameters
    parameters = MockParameters(
        t_delivery=[0.0, 1.0, 2.0],
        X_vac_interval=[0.5, 0.5, 0.5],
        omega_v=[0.1],
        p=[0.2],
        alpha_a=[0.3],
        alpha_s=[0.4],
        theta=[0.1],
        delta_e=[0.05],
        delta_r=[0.02],
        mu=[0.01],
        epsilon=[0.9],
        beta_s=[0.5],
        beta_a=[0.3],
        N_grid_size=[10],
        h=0.1,
        theta_T=0.1,
        mu_T=0.2,
        sigma_T=0.3,
        kappa=0.4,
        N_refinement_steps=5,
        N_radom_variables_per_step=10,
        seed=42,
        debug=false)

    state = MockState(
        S=[0.2],
        E=[0.1],
        I_S=[0.05],
        I_A=[0.03],
        R=[0.1],
        D=[0.02],
        V=[0.1],
        X_vac=[0.0],
        X_0_mayer=[0.0],
        K_stock_t=[1.0],
        time=[0.5],
        T=[0.1]
    )

    args = MockArgs(
        t=0.0,
        x=state,
        parameters=parameters,
        opt_policy=0.8,
        action_t=0.6
    )

    # Call the function
    result = compute_nsfd_iteration!(args)

    # Assertions
    @test length(result) == 17
    @test result[1] == args.t
    @test result[9] > 0  # CL_new
    @test result[10] > 0  # X_vac_new
    @test result[11] > 0  # X_0_mayer_new
    @test result[12] >= 0  # K_new
    @test result[13] == 0.2  # ou_temp
    @test result[14] == 0.1  # loss_vac
    @test result[15] == args.action_t
    @test result[16] == args.opt_policy
    @test result[17] == get_stencil_projection(args.x.time[1], args.parameters)
end