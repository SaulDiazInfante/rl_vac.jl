@kwdef mutable struct structState
    time::Float64
    S::Float64
    E::Float64
    I_S::Float64
    I_A::Float64
    R::Float64
    D::Float64
    V::Float64
    Conservative_Law::Float64
    X_vac::Float64
    previous_stage_cumulative_vaccination::Float64
    X_0_mayer::Float64
    K_stock_t::Float64
    T::Float64
    stock_loss::Float64
    action::Float64
    opt_policy::Float64
    t_index_interval::Int
end

Base.@kwdef mutable struct structModelParameters
    beta_s::Float64
    beta_a::Float64
    epsilon::Float64
    delta_e::Float64
    omega_v::Float64
    delta_r::Float64
    p::Float64
    alpha_a::Float64
    alpha_s::Float64
    theta::Float64
    mu::Float64
    psi_v::Float64
    theta_T::Float64
    mu_T::Float64
    sigma_T::Float64
    kappa::Float64
    N::Float64
end

Base.@kwdef mutable struct structNumericSolverParameters
    N_grid_size::Int64
    current_stage_interval::Vector{Float64}
    step_size_h::Float64
    N_refinement_per_step::Int64
    refinement_step_size_h::Float64
    N_radom_variables_per_step::Int64
    seed::Int64
    debug::Bool
end

Base.@kwdef mutable struct structInventoryParameters
    backup_inventory_level::Float64
    t_delivery::Vector{Float64}
    delivery_size_k::Vector{Float64}
    yll_weight::Float64
    yld_weight::Float64
    stock_cost_weight::Float64
    campaign_cost_weight::Float64
    operational_stock_levels::Vector{Float64}
end


function Base.copy(state::structState)::structState
    return structState(
        state.time,
        state.S,
        state.E,
        state.I_S,
        state.I_A,
        state.R,
        state.D,
        state.V,
        state.Conservative_Law,
        state.X_vac,
        state.previous_stage_cumulative_vaccination,
        state.X_0_mayer,
        state.K_stock_t,
        state.T,
        state.stock_loss,
        state.action,
        state.opt_policy,
        state.t_index_interval
    )
end

function Base.copy(InventoryParameters::structInventoryParameters)::structInventoryParameters
    return structInventoryParameters(
        InventoryParameters.backup_inventory_level,
        InventoryParameters.t_delivery,
        InventoryParameters.delivery_size_k,
        InventoryParameters.yll_weight,
        InventoryParameters.yld_weight,
        InventoryParameters.stock_cost_weight,
        InventoryParameters.campaign_cost_weight,
        InventoryParameters.operational_stock_levels
    )
end

function Base.copy(ModelParameters::structModelParameters)::structModelParameters
    return structModelParameters(
        ModelParameters.beta_s,
        ModelParameters.beta_a,
        ModelParameters.epsilon,
        ModelParameters.delta_e,
        ModelParameters.omega_v,
        ModelParameters.delta_r,
        ModelParameters.p,
        ModelParameters.alpha_a,
        ModelParameters.alpha_s,
        ModelParameters.theta,
        ModelParameters.mu,
        ModelParameters.psi_v,
        ModelParameters.theta_T,
        ModelParameters.mu_T,
        ModelParameters.sigma_T,
        ModelParameters.kappa,
        ModelParameters.N
    )
end

function Base.copy(NumericSolverParameters::structNumericSolverParameters)::structNumericSolverParameters
    return structNumericSolverParameters(
        NumericSolverParameters.N_grid_size,
        NumericSolverParameters.current_stage_interval,
        NumericSolverParameters.step_size_h,
        NumericSolverParameters.N_refinement_per_step,
        NumericSolverParameters.refinement_step_size_h,
        NumericSolverParameters.N_radom_variables_per_step,
        NumericSolverParameters.seed,
        NumericSolverParameters.debug
    )
end