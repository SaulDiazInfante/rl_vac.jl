"""
    compute_nsfd_iteration!(args::Dict{String,Any})::Vector{Float64}

This function computes the next iteration of a non-standard finite difference (NSFD) scheme for a given state and updates the state in-place. It models the dynamics of a system with compartments such as susceptible, exposed, infected, recovered, deceased, and vaccinated populations, as well as inventory and vaccination policies.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"state"`: The current state of the system, represented as a `structState` object.
  - `"inventory_parameters"`: Parameters related to inventory and delivery schedules.
  - `"model_parameters"`: Parameters defining the model dynamics, such as infection rates, recovery rates, and vaccination rates.
  - `"numeric_solver_parameters"`: Parameters for the numerical solver, including grid size, refinement steps, and random variable settings.

# Returns
- `Vector{Float64}`: A vector representing the updated state variables.

# Details
The function performs the following steps:
1. Extracts the current state and parameters from the `args` dictionary.
2. Computes intermediate variables such as the infection force (`lambda_f`), new compartment values (`S_new`, `E_new`, etc.), and auxiliary variables like cumulative vaccination and inventory levels.
3. Updates the state variables using the NSFD scheme, ensuring conservation laws are approximately satisfied.
4. Computes additional metrics such as temperature loss and vaccination loss using auxiliary functions.
5. Updates the `args["state"]` with the new state.

# Notes
- The function assumes that the state variables are normalized such that the total population (excluding deceased) is approximately 1.
- A warning is printed if the simulation time exceeds the delivery schedule or if conservation laws are violated.
- The function relies on external helper functions such as `get_stencil_projection`, `compute_mr_ou_temp_loss`, and `compute_cost`.

# Example Usage
"""
function compute_nsfd_iteration!(
    args::Dict{String,Any}
)::Vector{Float64}

    old_state = args["state"]
    inventory_par = args["inventory_parameters"]
    mod_par = args["model_parameters"]
    numeric_solver_par = args["numeric_solver_parameters"]
    dim = length(fieldnames(structState))

    x_new = zeros(Real, dim)
    S = old_state.S
    E = old_state.E
    I_S = old_state.I_S
    I_A = old_state.I_A
    R = old_state.R
    D = old_state.D
    V = old_state.V
    X_vac = old_state.X_vac
    X_vac_interval = old_state.previous_stage_cumulative_vaccination
    X_0_mayer = old_state.X_0_mayer
    K = old_state.K_stock_t
    opt_policy = old_state.opt_policy
    action = old_state.action

    index = get_stencil_projection(old_state.time, inventory_par)
    n_deliveries = size(inventory_par.t_delivery, 1)
    if (index >= n_deliveries)
        print("WARNING: simulation time OverflowErr")
    end

    omega_v = mod_par.omega_v
    p = mod_par.p
    alpha_a = mod_par.alpha_a
    alpha_s = mod_par.alpha_s
    theta = mod_par.theta
    delta_e = mod_par.delta_e
    delta_r = mod_par.delta_r
    mu = mod_par.mu
    epsilon = mod_par.epsilon
    beta_s = mod_par.beta_s
    beta_a = mod_par.beta_a
    #
    N_grid_size = numeric_solver_par.N_grid_size
    horizon_T = (
        inventory_par.t_delivery[index+1] - inventory_par.t_delivery[index]
    )
    h = horizon_T / N_grid_size
    x_new[1] = old_state.time + h
    psi = 1 - exp(-h)

    par_ou = Dict(
        :theta_T => mod_par.theta_T,
        :mu_T => mod_par.mu_T,
        :sigma_T => mod_par.sigma_T,
        :kappa => mod_par.kappa,
        :inventory_level => old_state.K_stock_t,
        :t0 => max(old_state.time - h, 0),
        :T_t_0 => old_state.T,
        :h_coarse => h,
        :n => numeric_solver_par.N_refinement_steps,
        :n_omega => numeric_solver_par.N_radom_variables_per_step,
        :seed => numeric_solver_par.seed,
        :debug_flag => numeric_solver_par.debug
    )
    # Compute new state variables
    hat_N_n = S + E + I_S + I_A + R + V
    if !isapprox(hat_N_n + D, 1.0; atol=1e-12, rtol=0)
        print("\n (----) WARNING: Conservative low overflow")

    end

    lambda_f = (beta_s * I_S + beta_a * I_A) * hat_N_n^(-1)
    S_new = (
        (1 - psi * mu) * S
        +
        psi * (mu * hat_N_n + omega_v * V + delta_r * R)
    ) / (1 + psi * (lambda_f + opt_policy * action))

    E_new = (
        (1 - psi * mu) * E
        +
        psi * lambda_f * (S_new + (1 - epsilon) * V)
    ) / (1 + psi * delta_e)

    I_S_new = (
        (1 - psi * mu) * I_S
        +
        psi * p * delta_e * E_new
    ) / (1 + psi * alpha_s)

    I_A_new = (
        (1 - psi * mu) * I_A
        +
        psi * (1 - p) * delta_e * E_new
    ) / (1 + psi * alpha_a)

    R_new = (
        (1 - psi * (mu + delta_r)) * R
        +
        psi * (
            (1 - theta) * alpha_s * I_S_new + alpha_a * I_A_new
        )
    )

    D_new = psi * theta * alpha_s * I_S_new + D

    V_new = (
        1 - psi * (
            (1 - epsilon) * lambda_f + mu + omega_v
        )
    ) * V + psi * (opt_policy * action) * S_new
    x_new[2:8] = [
        S_new,
        E_new,
        I_S_new,
        I_A_new,
        R_new,
        D_new,
        V_new
    ]
    CL_new = sum([
        S_new,
        E_new,
        I_S_new,
        I_A_new,
        R_new,
        D_new,
        V_new
    ])
    delta_X_vac = (opt_policy * action) * (S + E + I_A + R) * psi
    X_vac_new = X_vac + delta_X_vac

    temp_lambda_loss = compute_mr_ou_temp_loss(; par_ou...)
    loss_vac = temp_lambda_loss[:loss_j]
    ou_temp = temp_lambda_loss[:temp_j]

    current_stock = K
    stock_demand = X_vac_new - X_vac_interval
    K_new = maximum([0.0, -(stock_demand + loss_vac) + current_stock])
    X_0_mayer_new = X_0_mayer + psi * compute_cost(args)
    x_new[9] = CL_new
    x_new[10] = X_vac_new
    x_new[11] = X_vac_interval
    x_new[12] = X_0_mayer_new
    x_new[13] = K_new

    x_new[14] = ou_temp
    x_new[15] = loss_vac
    x_new[16] = action
    x_new[17] = opt_policy
    x_new[18] = index
    new_state = structState(
        x_new[1],
        x_new[2],
        x_new[3],
        x_new[4],
        x_new[5],
        x_new[6],
        x_new[7],
        x_new[8],
        x_new[9],
        x_new[10],
        x_new[11],
        x_new[12],
        x_new[13],
        x_new[14],
        x_new[15],
        x_new[16],
        x_new[17],
        x_new[18]
    )
    args["state"] = new_state
    return x_new
end
