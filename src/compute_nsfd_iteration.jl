function compute_nsfd_iteration!(
    t::Float64,
    x::DataFrame,
    opt_policy,
    a_t::Float64,
    k::Float64,
    parameters::DataFrame
)::Vector{Float64}

    # Unpack state variables
    x_new = zeros(17)
    x_new[1] = t
    S = x.S[1]
    E = x.E[1]
    I_S = x.I_S[1]
    I_A = x.I_A[1]
    R = x.R[1]
    D = x.D[1]
    V = x.V[1]
    X_vac = x.X_vac[1]
    X_0_mayer = x.X_0_mayer[1]
    index = get_stencil_projection(x.time[1], parameters)
    n_deliveries = size(parameters.t_delivery, 1)
    if (index >= n_deliveries)
        print("WARNING: simulation time OverflowErr")
    end
    # Unpack parameters
    X_vac_interval = parameters.X_vac_interval[index]
    K = x.K_stock[1]
    omega_v = parameters.omega_v[1]
    p = parameters.p[1]
    alpha_a = parameters.alpha_a[1]
    alpha_s = parameters.alpha_s[1]
    theta = parameters.theta[1]
    delta_e = parameters.delta_e[1]
    delta_r = parameters.delta_r[1]
    mu = parameters.mu[1]
    epsilon = parameters.epsilon[1]
    beta_s = parameters.beta_s[1]
    beta_a = parameters.beta_a[1]
    N_pop = parameters.N[1]
    #
    N_grid_size = parameters.N_grid_size[1]
    horizon_T = parameters.t_delivery[index+1] - parameters.t_delivery[index]
    h = horizon_T / N_grid_size
    psi = 1 - exp(-h)
    # Dictionary for the OU process
    par_ou = Dict(
        :theta_T => parameters[1, :theta_T],
        :mu_T => parameters[1, :mu_T],
        :sigma_T => parameters[1, :sigma_T],
        :kappa => parameters[1, :kappa],
        :inventory_level => K,
        :t0 => max(x.time[1] - h, 0),
        :T_t_0 => x.T[1],
        :h_coarse => h,
        :n => Int32(parameters[1, :N_refinement_steps]),
        :n_omega => Int32(parameters[1, :N_radom_variables_per_step]),
        :seed => Int32(parameters[1, :seed]),
        :debug_flag => parameters[1, :debug],
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
    ) / (1 + psi * (lambda_f + opt_policy * a_t))

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
    ) * V + psi * (opt_policy * a_t) * S_new
    x_new[2:8] = [
        S_new,
        E_new,
        I_S_new,
        I_A_new,
        R_new,
        D_new,
        V_new
    ]
    CL_new = sum(
        [
        S_new,
        E_new,
        I_S_new,
        I_A_new,
        R_new,
        D_new,
        V_new
    ]
    )
    delta_X_vac = (opt_policy * a_t) * (S + E + I_A + R) * psi
    X_vac_new = X_vac + delta_X_vac

    temp_lambda_loss = compute_mr_ou_temp_loss(; par_ou...)
    loss_vac = temp_lambda_loss[:loss_j]
    ou_temp = temp_lambda_loss[:temp_j]
    # Stock actualization:
    # current stock equals delivery plus stock of previous interval
    current_stock = k + X_vac_interval
    stock_demand = X_vac_new
    K_new = maximum([0.0, -(stock_demand + loss_vac) + current_stock])
    X_0_mayer_new = X_0_mayer + psi * compute_cost(x, parameters)
    x_new[9] = CL_new
    x_new[10] = X_vac_new
    x_new[11] = X_0_mayer_new
    x_new[12] = K_new

    x_new[13] = ou_temp
    x_new[14] = loss_vac
    x_new[15] = a_t
    x_new[16] = opt_policy
    x_new[17] = index
    return x_new
end
