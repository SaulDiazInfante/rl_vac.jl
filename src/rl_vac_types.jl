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
    N_refinement_steps::Int64
    N_radom_variables_per_step::Int64
    seed::Int64
    debug::Bool
end

Base.@kwdef mutable struct structInventoryParameters
    backup_inventory_level::Float64
    t_delivery::Vector{Float64}
    delivery_size_k::Vector{Float64}
    yll_weight::Vector{Float64}
    yld_weight::Vector{Float64}
    stock_cost_weight::Vector{Float64}
    campaign_cost_weight::Vector{Float64}
    operational_stock_levels::Vector{Float64}
end




initial_condition_path = "./data/initial_condition.json"
model_parameters_path = "./data/model_parameters.json"
numeric_solver_parameters_path = "./data/numeric_solver_parameters.json"
inventory_parameters_path = "./data/inventory_parameters.json"

initial_condition = json_to_struct(structState, initial_condition_path)
model_par = json_to_struct(structModelParameters, model_parameters_path)
numeric_solver_par = json_to_struct(
    structNumericSolverParameters, numeric_solver_parameters_path
)
inventory_par = json_to_struct(
    structInventoryParameters, inventory_parameters_path
)



args = Dict(
    "state" => initial_condition,
    "model_parameters" => model_par,
    "numeric_solver_parameters" => numeric_solver_par,
    "inventory_parameters" => inventory_par
)