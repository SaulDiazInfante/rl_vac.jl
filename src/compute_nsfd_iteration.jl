function compute_nsfd_iteration!(
    args...
)::Vector{Float64}

    x_new = zeros(17)
    x_new[1] = args.t
    S = args.x.S[1]
    E = args.x.E[1]
    I_S = args.x.I_S[1]
    I_A = args.x.I_A[1]
    R = args.x.R[1]
    D = args.x.D[1]
    V = args.x.V[1]
    X_vac = args.x.X_vac[1]
    X_0_mayer = args.x.X_0_mayer[1]
    index = get_stencil_projection(args.x.time[1], args.parameters)
    n_deliveries = size(args.parameters.t_delivery, 1)
    if (index >= n_deliveries)
        print("WARNING: simulation time OverflowErr")
    end
    # Unpack parameters
    X_vac_interval = args.parameters.X_vac_interval[index]
    K = args.x.K_stock_t
    omega_v = args.parameters.omega_v
    p = args.parameters.p[1]
    alpha_a = args.parameters.alpha_a[1]
    alpha_s = args.parameters.alpha_s[1]
    theta = args.parameters.theta[1]
    delta_e = args.parameters.delta_e[1]
    delta_r = args.parameters.delta_r[1]
    mu = args.parameters.mu[1]
    epsilon = args.parameters.epsilon[1]
    beta_s = args.parameters.beta_s[1]
    beta_a = args.parameters.beta_a[1]
    #
    N_grid_size = args.parameters.N_grid_size[1]
    horizon_T = args.parameters.t_delivery[index+1] - args.parameters.t_delivery[index]
    h = horizon_T / N_grid_size
    psi = 1 - exp(-h)
    # Dictionary for the OU process
    par_ou = Dict(
        :theta_T => args.parameters[1, :theta_T],
        :mu_T => args.parameters[1, :mu_T],
        :sigma_T => args.parameters[1, :sigma_T],
        :kappa => args.parameters[1, :kappa],
        :inventory_level => K,
        :t0 => max(args.x.time[1] - h, 0),
        :T_t_0 => args.x.T[1],
        :h_coarse => args.parameters.h,
        :n => Int32(args.parameters[1, :N_refinement_steps]),
        :n_omega => Int32(args.parameters[1, :N_radom_variables_per_step]),
        :seed => Int32(args.parameters[1, :seed]),
        :debug_flag => args.parameters[1, :debug],
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
    ) / (1 + psi * (lambda_f + args.opt_policy * args.action_t))

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
    ) * V + psi * (args.opt_policy * args.action_t) * S_new
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
    delta_X_vac = (args.opt_policy * args.action_t) * (S + E + I_A + R) * psi
    X_vac_new = X_vac + delta_X_vac

    temp_lambda_loss = compute_mr_ou_temp_loss(; par_ou...)
    loss_vac = temp_lambda_loss[:loss_j]
    ou_temp = temp_lambda_loss[:temp_j]
    # Stock actualization:
    # current stock equals delivery plus stock of previous interval
    current_stock = k
    stock_demand = X_vac_new - X_vac_interval
    K_new = maximum([0.0, -(stock_demand + loss_vac) + current_stock])
    X_0_mayer_new = X_0_mayer + psi * compute_cost(x, args.parameters)
    x_new[9] = CL_new
    x_new[10] = X_vac_new
    x_new[11] = X_0_mayer_new
    x_new[12] = K_new

    x_new[13] = ou_temp
    x_new[14] = loss_vac
    x_new[15] = args.action_t
    x_new[16] = args.opt_policy
    x_new[17] = index
    return x_new
end
