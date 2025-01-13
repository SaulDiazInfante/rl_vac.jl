using JSON, DataFrames, Distributions
using CSV, LaTeXStrings, PlotlyJS
using Dates, ProgressMeter, Interpolations
using CairoMakie, StatsBase, MakiePublication, Printf
using Debugger

"""
    load_parameters(json_file_name="./data/parameters_model.json")

Returns a DataFrame with all parameters to run the MDP.
In addition, this function is responsible for loading the  parameters
required for the ODE model and simulation configuration.
---
# Arguments
- `json_file_name::String`: Path of a .json file with parameters.
"""
function load_parameters(json_file_name="./data/parameters_model.json")
    file_JSON = open(json_file_name, "r")
    parameters = file_JSON |> JSON.parse |> DataFrame
    close(file_JSON)
    return parameters
end

"""
    get_stencil_projection(t, parameters)

Returns the index of corresponding projection of time t to the stencil and in accordance with the parameters vector.

# Arguments
- `t::Float`: time to project to the stencil
- `parameters::DataFrame`: Data Frame loaded with 
    `load_parameters(...)` function 
---
"""
function get_stencil_projection(t, parameters)
    stencil = parameters.t_delivery
    grid = findall(t .>= stencil)
    projection = maximum(grid)
    return projection
end

"""
    rhs_evaluation!(t, x, opt_policy, a_t, k, parameters)

Approximate the solution to SEIRVDX_vac ODE by returning an array with
the right-hand side evaluation of The Non-Standard recurrence; refer to
the corresponding article for formulation.

# Arguments
- `t::Float`: time 
- `x::DataFrame`: System current state
- `a_t::Float`: action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: current level of the vaccine-stock.
- `parameters::DataFrame`: current parameters.
...
"""
function rhs_evaluation!(
    t::Float64,
    x,
    opt_policy,
    a_t::Float64,
    k::Float64,
    parameters
)
    #TODO: Check dimesions with other scripts
    x_new = zeros(15)
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
    index = get_stencil_projection(x.t[1], parameters)
    n_deliveries = size(parameters.t_delivery, 1)
    if (index >= n_deliveries)
        print("WARNING: simulation time OverflowErr")
    end
    X_vac_interval = parameters.X_vac_interval[index]
    K = x.K_stock[1]
    stock_condition = parameters.low_stock[1] / parameters.N[1]
    omega_v = parameters.omega_v[1]
    psi_v = parameters.psi_v[index]
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

    N_grid_size = parameters.N_grid_size[1]
    T = parameters.t_delivery[index+1] - parameters.t_delivery[index]
    h = T / N_grid_size
    psi = 1 - exp(-h)
    hat_N_n = S + E + I_S + I_A + R + V

    lambda_f = (beta_s * I_S + beta_a * I_A) * hat_N_n^(-1)

    S_new = ((1 - psi * mu) * S +
             psi * (mu * hat_N_n + omega_v * V
                    + delta_r * R)
    ) / (1 + psi * (lambda_f + opt_policy * a_t))

    E_new = ((1 - psi * mu) * E
             +
             psi * lambda_f * (S_new + (1 - epsilon) * V)
    ) / (1 + psi * delta_e)

    I_S_new = ((1 - psi * mu) * I_S
               +
               psi * p * delta_e * E_new
    ) / (1 + psi * alpha_s)

    I_A_new = ((1 - psi * mu) * I_A
               +
               psi * (1 - p) * delta_e * E_new
    ) / (1 + psi * alpha_a)

    R_new = ((1 - psi * (mu + delta_r)) * R
             +
             psi * ((1 - theta) * alpha_s * I_S_new + alpha_a * I_A_new))

    D_new = psi * theta * alpha_s * I_S_new + D

    V_new = ((1 - psi * ((1 - epsilon) * lambda_f + mu + omega_v)) * V
             +
             psi * (opt_policy * a_t) * S_new)
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
    sign_efective_stock =
        sign(
            k - (X_vac_new - X_vac_interval) - stock_condition
        )
    sign_efective_stock_test = (sign_efective_stock < 0.0)

    # TODO: Fix Stock    
    if sign_efective_stock_test
        X_C = k - parameters.low_stock[1] / parameters.N[1]
        T_index = get_stencil_projection(x.t[1], parameters)
        t_lower_interval = x.t[1]
        t_upper_interval = parameters.t_delivery[T_index+1]
        projected_jabs = X_vac_new - X_vac_interval
        psi_v = -log(1.0 - X_C) / (t_upper_interval - t_lower_interval)
        parameters.psi_v[index] = psi_v
        a_t = psi_v
        scaled_psi_v = psi_v * N_pop
        msg_01 = "\n\t normalized Psi_V: $(@sprintf("%.2f", psi_v))"
        msg_02 = "\n\t norminal Psi_V: $(
                        @sprintf("%.2f", scaled_psi_v
                )
        )"
        print("\n=================================")
        print("\nt_lower: ", x.t[1])
        print("\nt_upper: ", t_upper_interval)
        print("\nRecalibrating Psi_V: ")
        print(msg_01)
        print(msg_02)
        print("\nActual stock: ", k * N_pop)
        print("\n\tProjected Jabs: $(
                        @sprintf("%.2f", projected_jabs * N_pop)
                )
        ")
        print("\n---------------------------------\n")

        S_new = ((1 - psi * mu) * S +
                 psi * (mu * hat_N_n + omega_v * V
                        + delta_r * R)
        ) / (1 + psi * (lambda_f + a_t))

        E_new = (
            (1 - psi * mu) * E
            +
            psi * lambda_f * (S_new + (1 - epsilon) * V)
        ) / (1 + psi * delta_e)

        I_S_new = ((1 - psi * mu) * I_S
                   +
                   psi * p * delta_e * E_new
        ) / (1 + psi * alpha_s)

        I_A_new = ((1 - psi * mu) * I_A
                   +
                   psi * (1 - p) * delta_e * E_new
        ) / (1 + psi * alpha_a)

        R_new = ((1 - psi * (mu + delta_r)) * R
                 +
                 psi * (
            (1 - theta) * alpha_s * I_S_new
            +
            alpha_a * I_A_new
        )
        )
        D_new = psi * theta * alpha_s * I_S_new + D
        V_new = (
            (
                1 - psi * ((1 - epsilon) * lambda_f
                           + mu + omega_v
                )) * V
            +
            psi * (a_t) * S_new
        )

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
        delta_X_vac = (a_t) * (S + E + I_A + R) * psi
        X_vac_new = X_vac + delta_X_vac
    end
    K_new = maximum([0.0, k - (X_vac_new - X_vac_interval)])
    X_0_mayer_new = X_0_mayer + psi * compute_cost(x, parameters)
    x_new[9] = CL_new
    x_new[10] = X_vac_new
    x_new[11] = X_0_mayer_new
    x_new[12] = K_new
    x_new[13] = a_t
    x_new[14] = opt_policy
    x_new[15] = index
    return x_new
end

"""
    get_stochastic_perturbation(json_file_name="./data/parameters_model.json")

Returns a random perturabation of the delivery plan enclosed in the json
file. To do this, the function loads the parameters as the dataframe
`par` and then sum to the deliveries times and stock shimpments a random
variable.

---
"""
function get_stochastic_perturbation(
    json_file_name="./data/parameters_model.json"
)
    par = load_parameters(json_file_name)
    t_delivery = par.t_delivery
    k_stock = par.k_stock
    aux_t = zeros(length(t_delivery))
    aux_k = zeros(length(t_delivery))
    delta_t = 0.0
    t = 1
    aux_t[t] = t_delivery[t]
    aux_k[t] = k_stock[t]
    for t in 2:length(t_delivery)
        eta_t = Truncated(
            Normal(
                k_stock[t],
                0.5 * sqrt(k_stock[t])
            ),
            0, 2 * k_stock[t]
        )
        delta_t = t_delivery[t] - t_delivery[t-1]
        tau = Normal(delta_t, 1.0 * sqrt(delta_t))
        # tau = Uniform(.25 * delta_t, 1.5 * delta_t) 
        # tau = Exponential(64.0); 
        delta_tau = rand(tau, 1)[1]
        # aux_t[t] = aux_t[t-1] + delta_t * (1.0 + rand(u, 1)[1])  
        aux_t[t] = aux_t[t-1] + delta_tau
        xi_t = rand(eta_t, 1)[1]
        aux_k[t] = xi_t
    end
    par.t_delivery = aux_t
    par.k_stock = aux_k
    return par
end
"""
    compute_cost(x, parameters)

Compute the functional cost given the current 
state and action.

# Arguments
- `t::Float`: time 
- `x::DataFrame`: System current state
- `a_t::Float`: action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: current level of the vaccine-stock.
- `parameters::DataFrame`: current parameters.
...
"""

function compute_cost(x, parameters)
    m_yll = parameters.yll_weight[1]
    m_yld = parameters.yld_weight[1]
    m_stock_cost = parameters.stock_cost_weight[1]
    m_campaing_cost = parameters.campaing_cost_weight[1]

    N_grid_size = parameters.N_grid_size[1]
    #unpack initial condition
    S_0 = parameters.S_0[1]
    E_0 = parameters.E_0[1]
    I_S_0 = parameters.I_S_0[1]
    I_A_0 = parameters.I_A_0[1]
    R_0 = parameters.R_0[1]
    D_0 = parameters.D_0[1]
    V_0 = parameters.V_0[1]
    X_vac_0 = 0.0
    X_0_mayer_0 = x.X_0_mayer
    k_0 = parameters.k_stock[1] / parameters.N[1]
    # #    "psi_v": 0.00123969,
    CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
    omega_v = parameters.omega_v[1]
    #a_t = 0.0
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
    header_strs = [
        "t", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
        "action", "opt_policy"
    ]
    x_0 = [
        0.0, S_0, E_0, I_S_0, I_A_0, R_0,
        D_0, V_0, CL0, X_vac_0, X_0_mayer_0, k_0, 0.0,
        1.0
    ]
    x_0 = DataFrame(
        Dict(
            zip(
                header_strs,
                x_0
            )
        )
    )

    yll = m_yll * p * delta_e * (x.E - x_0.E)
    yld = m_yld * theta * alpha_s * (x.E - x_0.E)
    stock_cost = m_stock_cost * (x.K_stock - x_0.K_stock)
    campaing_cost = m_campaing_cost * (x.X_vac - x_0.X_vac)
    return sum([yll, yld, stock_cost, campaing_cost])[1]
end

"""
    compute_cost(x, parameters)

Compute the functional cost given the current 
state and action.

# Arguments
- `t::Float`: time 
- `x::DataFrame`: System current state
- `a_t::Float`: action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: current level of the vaccine-stock.
- `parameters::DataFrame`: current parameters.
...
"""
function compute_cost(x, parameters)
    m_yll = parameters.yll_weight[1]
    m_yld = parameters.yld_weight[1]
    m_stock_cost = parameters.stock_cost_weight[1]
    m_campaing_cost = parameters.campaing_cost_weight[1]

    N_grid_size = parameters.N_grid_size[1]
    #unpack initial condition
    S_0 = parameters.S_0[1]
    E_0 = parameters.E_0[1]
    I_S_0 = parameters.I_S_0[1]
    I_A_0 = parameters.I_A_0[1]
    R_0 = parameters.R_0[1]
    D_0 = parameters.D_0[1]
    V_0 = parameters.V_0[1]
    X_vac_0 = 0.0
    X_0_mayer_0 = x.X_0_mayer
    k_0 = parameters.k_stock[1] / parameters.N[1]
    # #    "psi_v": 0.00123969,
    CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
    omega_v = parameters.omega_v[1]
    #a_t = 0.0
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
    header_strs = [
        "t", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
        "action", "opt_policy"
    ]
    x_0 = [
        0.0, S_0, E_0, I_S_0, I_A_0, R_0,
        D_0, V_0, CL0, X_vac_0, X_0_mayer_0, k_0, 0.0,
        1.0
    ]
    x_0 = DataFrame(
        Dict(
            zip(
                header_strs,
                x_0
            )
        )
    )

    yll = m_yll * p * delta_e * (x.E - x_0.E)
    yld = m_yld * theta * alpha_s * (x.E - x_0.E)
    stock_cost = m_stock_cost * (x.K_stock - x_0.K_stock)
    campaing_cost = m_campaing_cost * (x.X_vac - x_0.X_vac)
    return sum([yll, yld, stock_cost, campaing_cost])[1]

end

"""
    get_vaccine_stock_coverage(k, parameters)

Returns el percentage of popullation to vaccine when the inventory 
level of interest is k and use the current parameters 

# Arguments
- `k:: Float64:` Current fraction of the maximum vaccine-stock level 
- `parameters::DataFrame`: current parameters.
...
"""
function get_vaccine_stock_coverage(k, parameters)
    l_s = parameters.low_stock[1] / parameters.N[1]
    x_coverage = maximum([k - l_s, 0.0])
    return x_coverage
end

"""
    get_vaccine_action!(X_c, t, parameters)

Returns a vaccine action.
This descision is calcualted in order to
reach after a horizont time t_horizon a coverage X_C.
    
# Arguments
- `X_c::Float`: Current coverage population at time t
- `t::Float`: time
- `parameters::DataFrame`: current parameters.
...
"""
function get_vaccine_action!(X_C, t, parameters)
    id = get_stencil_projection(t, parameters)
    t_initial_interval = parameters.t_delivery[id-1]
    t_horizon = t - t_initial_interval
    psi_v = -log(1.0 - X_C) / (t_horizon)
    a_t = psi_v
    parameters.psi_v[id-1] = psi_v
    return a_t
end
"""
    get_interval_solution!(
        time_interval, x, opt_policy, a_t, k, parameters
    )

Generate the values of all compartments for points of a given interval time 

# Arguments
- `time_interval::Float`: time.
- `x::DataFrame`: System current state.
- `opt_policy::Float`: Optimal level of vaccine inventory coverage. 
- `a_t::Float`: Action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: Current level of the vaccine-stock.
- `parameters::DataFrame`: Current parameters.
...
"""
function get_interval_solution!(
    time_interval, x, opt_policy, a_t, k, parameters
)
    t_0 = time_interval[1]
    index = get_stencil_projection(t_0, parameters)
    N_grid_size = parameters.N_grid_size[index]
    sol = zeros(Float64, N_grid_size, 15)

    S_0 = x.S[1]
    E_0 = x.E[1]
    I_S_0 = x.I_S[1]
    I_A_0 = x.I_A[1]
    R_0 = x.R[1]
    D_0 = x.D[1]
    V_0 = x.V[1]
    X_0_mayer_0 = x.X_0_mayer[1]
    X_vac_0 = x.X_vac[1]
    k_0 = x.K_stock[1]
    CL0 = x.CL[1]
    x_00 = [
        t_0,
        S_0, E_0, I_S_0,
        I_A_0, R_0, D_0,
        V_0, CL0, X_vac_0,
        X_0_mayer_0, k_0,
        a_t, opt_policy, index
    ]

    sol[1, :] = x_00
    header_strs = [
        "t",
        "S", "E", "I_S",
        "I_A", "R", "D",
        "V", "CL", "X_vac",
        "X_0_mayer", "K_stock", "action",
        "opt_policy", "t_index_interval"
    ]
    for j = 2:N_grid_size
        #x_new = rhs_evaluation(x_old, parameters)
        S_old = sol[j-1, :]
        S_old_df = DataFrame(
            Dict(
                zip(
                    header_strs,
                    S_old
                )
            )
        )
        t = time_interval[j]
        #        if t >= 180
        #            print("DEV: interruption")
        #        end
        sol[j, :] = rhs_evaluation!(t, S_old_df, opt_policy, a_t, k, parameters)
    end
    return sol
end

"""
    get_solution_path!(parameters::DataFrame)
    Compute a path of the solution process
# Arguments
- `parameters::DataFrame: Current values for model parameters and 
    simulation configuration.
...
"""
function get_solution_path!(parameters::DataFrame)
    N_grid_size = parameters.N_grid_size[1]
    solution = zeros(Float64, N_grid_size, 13)
    #unpack initial condition
    S_0 = parameters.S_0[1]
    E_0 = parameters.E_0[1]
    I_S_0 = parameters.I_S_0[1]
    I_A_0 = parameters.I_A_0[1]
    R_0 = parameters.R_0[1]
    D_0 = parameters.D_0[1]
    V_0 = parameters.V_0[1]
    X_vac_0 = 0.0
    X_0_mayer = parameters.X_0_mayer[1]
    k_0 = parameters.k_stock[1] / parameters.N[1]
    operational_levels = parameters.operational_stock_levels
    # #    "psi_v": 0.00123969,
    CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
    header_strs = [
        "time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
        "action", "opt_policy", "t_interval_idx"
    ]

    x_0_vector = [
        0.0, S_0, E_0,
        I_S_0, I_A_0, R_0,
        D_0, V_0, CL0,
        X_vac_0, X_0_mayer, k_0,
        0.0, 1.0, 1
    ]
    hat_N_n_0 = sum(x_0_vector[2:8]) - D_0
    x_0 = DataFrame(
        Dict(
            zip(
                header_strs,
                x_0_vector
            )
        )
    )
    #
    # Solution on the first delivery time period
    #
    X_C = get_vaccine_stock_coverage(k_0, parameters)
    t_delivery_1 = parameters.t_delivery[2]
    # We must optimize our decision-making process by conducting a
    # thorough search. This entails exploring all possible options to
    # determine the best #course of action.
    # We begin by considering the number of calculated jabs needed to
    # achieve the desired vaccine coverage. 

    a_t = get_vaccine_action!(X_C, t_delivery_1, parameters)
    simulation_interval =
        LinRange(
            parameters.t_delivery[1],
            parameters.t_delivery[2],
            N_grid_size
        )
    #
    time_horizon_1 = parameters.t_delivery[2]
    t_interval_1 = LinRange(0, time_horizon_1, N_grid_size)
    opt_policy = operational_levels[end]
    solution_1 =
        get_interval_solution!(
            t_interval_1,
            x_0,
            opt_policy,
            a_t,
            k_0,
            parameters
        )
    candidate_solution = solution_1
    opt_cost = candidate_solution[end, 11]
    for rho_k in operational_levels[1:(end-1)]
        policy = rho_k
        solution_1 = get_interval_solution!(
            t_interval_1,
            x_0,
            policy,
            a_t,
            k_0,
            parameters
        )
        cost = solution_1[end, 11]
        if cost <= opt_cost
            opt_cost = cost
            candidate_solution = solution_1
            opt_policy = policy
        end
    end
    opt_solution_1 = candidate_solution
    prefix = "df_solution_"
    sufix = "1.csv"
    file = "./data/" * prefix * sufix
    df_solution_1 =
        save_interval_solution(
            opt_solution_1;
            file_name=file
        )
    solution_list = []
    solution_list = push!(solution_list, df_solution_1)
    df_solution = DataFrame()
    df_solution = [df_solution; df_solution_1]
    #
    # Solution on each t_interval

    for t in 2:(length(parameters.t_delivery)-1)
        h = (parameters.t_delivery[t+1] -
             parameters.t_delivery[t]) / N_grid_size
        t_interval =
            LinRange(
                parameters.t_delivery[t] +
                h,
                parameters.t_delivery[t+1],
                N_grid_size
            )
        # initial condition for left bound interval
        x_t = solution_list[t-1][end, :]
        k_t = x_t.K_stock + parameters.k_stock[t] / parameters.N[t]
        parameters.X_vac_interval[t] = x_t.X_vac
        X_Ct = get_vaccine_stock_coverage(k_t, parameters)
        t_delivery_t = parameters.t_delivery[t+1]
        # TODO: Code the implementation for a sequential decision
        a_t = get_vaccine_action!(X_Ct, t_delivery_t, parameters)
        ## Optimal Decision
        opt_policy = operational_levels[end]
        solution_t = get_interval_solution!(
            t_interval,
            x_t,
            opt_policy,
            a_t,
            k_t,
            parameters
        )
        ### optimization by exaustive search
        candidate_solution = solution_t
        opt_cost = candidate_solution[end, 11]
        for rho_k in operational_levels[1:(end-1)]
            policy = rho_k
            solution_t = get_interval_solution!(
                t_interval,
                x_t,
                policy,
                a_t,
                k_t,
                parameters
            )
            cost = solution_t[end, 11]
            if cost <= opt_cost
                opt_cost = cost
                candidate_solution = solution_t
                opt_policy = policy
            end
        end
        opt_solution_t = candidate_solution
        sufix = "$(t)" * ".csv"
        file = "./data/" * prefix * sufix
        df_solution_t =
            save_interval_solution(
                opt_solution_t;
                file_name=file
            )
        solution_list = push!(solution_list, df_solution_t)
        df_solution = [df_solution; df_solution_t]
    end
    CSV.write("./data/df_solution.csv", df_solution)
    return x_0, df_solution
end
"""
    save_interval_solution(time, x;
        header_strs =
            ["time", "S", "E",
            "I_S", "I_A", "R",
            "D", "V", "CL",
            "X_vac", "K_stock", "action"],
        file_name = "solution_interval.csv"
        )

Return and save the state of model on discrete time values between time arrive deliveries.       

# Arguments
- `time::Vector`: Discrete time values where the system state is approximate.  
- `x::DataFrame`: System current state
- `header_strs::Vector`: action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: current level of the vaccine-stock.
- `parameters::DataFrame`: current parameters.
...
"""
function save_interval_solution(x;
    header_strs=
    ["time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
        "action", "opt_policy"
    ],
    file_name="solution_interval.csv"
)
    data = x
    df_solution = (
        DataFrame(
        Dict(
            zip(
                header_strs,
                [data[:, i] for i in 1:size(data, 2)]
            )
        )
    )
    )
    CSV.write(file_name, df_solution)
    return df_solution
end
"""
    montecarlo_sampling(sampling_size=10000,
    json_file_name="parameters_model.json")

Given sampling size  and a valid file of parameters.
This function computes and save a number of sampling_size with 
the parameters enclosed in the file .json.

# Arguments
- `sampling_size::Int64`: Number of samples.
- `json_file_name::String` Path of json file with all parameters. 
...
"""
function montecarlo_sampling(
    sampling_size=10000,
    json_file_name="data/parameters_model.json"
)
    parameters = load_parameters(json_file_name)
    x0, df = get_solution_path!(parameters)
    #
    # 
    df_par = DataFrame()
    df_mc = DataFrame()
    #
    idx_path_par = ones(Int64, size(parameters)[1])
    idx_path = ones(Int64, size(df)[1])
    #
    insertcols!(parameters, 31, :idx_path => idx_path_par)
    insertcols!(df, 13, :idx_path => idx_path)
    df_mc = [df_mc; df]
    df_par = [df_par; parameters]
    n = sampling_size
    p = Progress(n, 1, "Sampling")
    for idx in 2:sampling_size
        par = get_stochastic_perturbation(json_file_name)
        x0, df = get_solution_path!(par)
        idx_path_par = idx * ones(Int64, size(par)[1])
        idx_path = idx * ones(Int64, size(df)[1])
        insertcols!(par, 31, :idx_path => idx_path_par)
        insertcols!(df, 13, :idx_path => idx_path)
        df_par = [df_par; par]
        df_mc = [df_mc; df]
        next!(p)
    end
    # saving par time seires
    prefix_file_name = "df_par"
    #
    d = Dates.now()
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    sufix_file_name = ".csv"
    csv_file_name = prefix_file_name * tag * sufix_file_name
    path_par = "./data/" * csv_file_name
    CSV.write(path_par, df_par)
    # 
    prefix_file_name = "df_mc"
    csv_file_name = prefix_file_name * sufix_file_name
    path_mc = "./data/" * csv_file_name
    CSV.write(path_mc, df_mc)
    return df_par, df_mc, path_par, path_mc
end
"""
    get_interpoled_solution(trajectory::DataFrame, line_time)
    iterpolate a sampled path of the solution process 
    respect a given interval time with line_time

# Arguments
- `trajectory::DataFrame`: Solution path to invterpolate.
- `line_time::Vector`: Time points for interpolation
...
"""
function get_interpolated_solution(trajectory::DataFrame, line_time)
    state_names = [
        "time",
        "D", "E", "I_A", "I_S", "K_stock",
        "R", "S", "V", "X_vac", "action"
    ]
    par = load_parameters()
    k = par.low_stock / par.N
    k = k[1]
    time = trajectory.time
    dim = [length(line_time), length(state_names)]
    interpolated_time_states = zeros(dim[1], dim[2])
    interpolated_time_states[:, 1] = line_time
    df = DataFrame(interpolated_time_states, state_names)
    for state_name in state_names
        state = trajectory[!, Symbol(state_name)]
        interpolated_state = linear_interpolation(
            time, state, extrapolation_bc=Line())
        interpolated_state_eval = interpolated_state.(line_time)
        if state_name == "K_stock"
            K = k * ones(length(interpolated_state_eval))
            aux = [interpolated_state_eval'; K']
            interpolated_state_eval = maximum(aux, dims=1)[:]
        end
        df[!, Symbol(state_name)] = interpolated_state_eval
    end
    return df
end
"""
    get_simulation_statistics(
        data_path="./data/df_mc.csv",
        parameters_path = "par.json"
    )
    returns the median, and qunatiles [0.25, 0.95] for each time of
    simulation.
    
# Arguments
- `data_paht::String`: Path with the output of montecarlo sampling
- `parameters_path::String`: Path with the json source for config parameters
...
"""
function get_simulation_statistics(
    data_path="./data/df_mc.csv",
    parameters_path="./data/parameters_model.json"
)
    trajectories = CSV.read(data_path, DataFrame)
    dropmissing!(trajectories)
    # obtain dimmensions
    parameters = load_parameters()
    idx_0 = (trajectories.idx_path .== 1)
    query = trajectories[idx_0, :]
    line_time = query.time
    #
    #
    #
    interpolated_trajectory_1 =
        get_interpolated_solution(query, line_time)
    idx_path = unique(trajectories, :idx_path).idx_path
    df_interpolated = DataFrame()
    df_interpolated = [df_interpolated; interpolated_trajectory_1]
    n = size(idx_path[2:end])[1]
    p = Progress(n, 1, "Interpolating")
    for j in idx_path[2:end]
        idx_j = (trajectories.idx_path .== j)
        trajectory_j = trajectories[idx_j, :]
        #print("\n path: ", j)
        interpolated_trajectory_j =
            get_interpolated_solution(trajectory_j, line_time)
        df_interpolated = [df_interpolated; interpolated_trajectory_j]
        next!(p)
    end
    # saving interpolated time seires
    prefix_file_name = "df_interpolated"
    d = Dates.now()
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    sufix_file_name = ".csv"
    csv_file_name = prefix_file_name * tag * sufix_file_name
    path_par = "./data/" * csv_file_name
    CSV.write(path_par, df_interpolated)
    # Gettin statistics over the firs observation
    t_zero = line_time[1]
    idx_t = (df_interpolated.time .== t_zero)
    #
    query_on_time_zero = df_interpolated[idx_t, :]
    median_state_t = [median(c) for c in eachcol(query_on_time_zero)]
    lower_q_state_t = [quantile(c, 0.05) for c in eachcol(query_on_time_zero)]
    upper_q_state_t = [quantile(c, 0.95) for c in eachcol(query_on_time_zero)]
    header_strs = names(query_on_time_zero)
    df_median_path = DataFrame()
    df_lower_q_path = DataFrame()
    df_upper_q_path = DataFrame()
    df_median_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    median_state_t
                )
            )
        )
    df_lower_q_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    lower_q_state_t
                )
            )
        )
    df_upper_q_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    upper_q_state_t
                )
            )
        )
    df_median_path = [df_median_path; df_median_path_]
    df_lower_q_path = [df_lower_q_path; df_lower_q_path_]
    df_upper_q_path = [df_upper_q_path; df_upper_q_path_]
    time_ = line_time
    for t in time_[2:end]
        idx_t = (df_interpolated.time .== t)
        query_on_time = df_interpolated[idx_t, :]
        median_state_t = [median(c) for c in eachcol(query_on_time)]
        lower_q_state_t = [quantile(c, 0.05) for c in eachcol(query_on_time)]
        upper_q_state_t = [quantile(c, 0.95) for c in eachcol(query_on_time)]
        #       
        df_median_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        median_state_t
                    )
                )
            )
        df_lower_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        lower_q_state_t
                    )
                )
            )
        df_upper_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        upper_q_state_t
                    )
                )
            )
        df_median_path = [df_median_path; df_median_path_]
        df_lower_q_path = [df_lower_q_path; df_lower_q_path_]
        df_upper_q_path = [df_upper_q_path; df_upper_q_path_]
    end
    prefix_file_names = ["df_median", "df_lower_q", "df_upper_q"]
    data = [df_median_path, df_lower_q_path, df_upper_q_path]
    d = Dates.now()
    sufix = ".csv"
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    for i = 1:3
        prefix = prefix_file_names[i]
        csv_file_name_ = "./data/" * prefix * sufix_file_name
        csv_file_name = "./data/" * prefix * tag * sufix_file_name
        CSV.write(csv_file_name_, data[i])
        CSV.write(csv_file_name, data[i])
    end
    N = parameters.N[1]
    trace1 =
        PlotlyJS.scatter(
            x=df_median_path.time,
            y=N * df_median_path.I_S,
            mode="lines",
            name="I_S")
    trace2 =
        PlotlyJS.scatter(
            x=df_lower_q_path.time,
            y=N * df_lower_q_path.I_S,
            mode="lines",
            name="lower_I_S"
        )
    trace3 =
        PlotlyJS.scatter(
            x=df_upper_q_path.time,
            y=N * df_upper_q_path.I_S,
            mode="lines",
            name="upper_I_S"
        )
    fig = PlotlyJS.plot([trace1, trace2, trace3])
    open("./plot_fig3.html", "w") do io
        PlotlyBase.to_html(io, fig.plot)
    end
    # TODO implement return
    return data
end
"""
Returns a figure that encloses a panel visualization with 
vaccine stock,
vaccination rate, and optimal decision at the left, 
and the Infecte class evulution on the right for a number of 
n_paths realizations.

# Arguments
- `df_mc::DataFrame`: DataFrame with the MonteCarlo Sampling
- `pop_size::Float64`: Population size to scalate Incidence and Number of doses
- `n_paths::Int`: Number of sampling paths to plot
"""

function get_panel_plot(
    df_mc::DataFrame,
    pop_size::Float64,
    n_paths::Int,
    file_name::AbstractString
)
    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 190
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f = 72.0 .* size_inches
    f = Figure(
        resolution=size_pt_f,
        fontsize=12
    )

    axtop = Axis(f[1, 1], ylabel="Stock")
    axmidle = Axis(f[2, 1], ylabel="Vaccination rate")
    axbottom = Axis(f[3, 1], xlabel="time (day)", ylabel="Decision")
    ax_right = Axis(f[:, 2], xlabel="time (day)", ylabel=L"I_S")
    axs = [axtop, axmidle, axbottom, ax_right]
    labels = ["(A)", "(B)", "(C)", "(D)"]
    font_size = 18
    hv_offset = (4, -1)

    for (ax, label) in zip(axs, labels)
        text!(
            ax,
            0, 1,
            text=label,
            font=:bold,
            align=(:left, :top),
            offset=hv_offset,
            space=:relative,
            fontsize=font_size
        )
    end

    for i in 1:n_paths
        data_path_i = filter(
            :idx_path => n -> n == i,
            df_mc
        )
        lines!(
            axtop,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :K_stock]
        )
        band!(
            axtop,
            data_path_i[!, :time],
            0.0,
            pop_size * data_path_i[!, :K_stock],
            alpha=0.3
        )
        lines!(
            axmidle,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :opt_policy] .* data_path_i[!, :action]
        )
        band!(
            axmidle,
            data_path_i[!, :time],
            0.0,
            pop_size * data_path_i[!, :opt_policy] .* data_path_i[!, :action],
            alpha=0.2
        )
        lines!(
            axbottom,
            data_path_i[!, :time],
            data_path_i[!, :opt_policy]
        )
        lines!(
            ax_right,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :I_S]
        )
        filename = file_name * "_0" * string(i) * ".png"
        save(filename, f, px_per_unit=10)
    end
    filename = file_name * ".png"
    save(filename, f, px_per_unit=10)
    return f
end

"""
Returns a figure that encloses a panel visualization with 
the confidence bands from quartiles 0.5 and .95 for the variables:
vaccine stock, vaccination rate, and Symptomatic Infected.
Also plots a counts for the decision at the left, 
and the Infecte class evulution on the right for a number of 
n_paths realizations.

# Arguments
- `df_lower_q::DataFrame`: 
- `df_median::DataFrame`:
- `df_upper_q::DataFrame`:
- `df_ref::DataFrame`: DataFrame with the opt_Policy col from MonteCarlo Sampling 
- `pop_size::Float64`:
- `file_name::AbstractString`:
"""

function get_confidence_bands(
    df_lower_q::DataFrame,
    df_median::DataFrame,
    df_upper_q::DataFrame,
    df_mc::DataFrame,
    pop_size::Float64,
    file_name::AbstractString
)

    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 190
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f = 72.0 .* size_inches

    f = Figure(
        resolution=size_pt_f,
        fontsize=12
    )

    # colors
    # color_q = (:azure, 1.0)
    color_m = (:orange, 0.4)
    color_ref = (:grey0, 1.0)
    axtop = Axis(
        f[1, 1],
        ylabel="Stock"
    )
    axmidle = Axis(
        f[2, 1],
        xlabel="time (day)",
        ylabel="Vaccination rate"
    )
    axbottom = Axis(
        f[3, 1],
        xlabel="Decision",
        ylabel="Count"
    )
    axright = Axis(
        f[1:3, 2],
        xlabel="time (day)",
        ylabel=L"I_S"
    )

    axs = [axtop, axmidle, axbottom, axright]
    labels = ["(A)", "(B)", "(C)", "(D)"]
    font_size = 18
    hv_offset = (4, -1)

    for (ax, label) in zip(axs, labels)
        text!(
            ax,
            0, 1,
            text=label,
            font=:bold,
            align=(:left, :top),
            offset=hv_offset,
            space=:relative,
            fontsize=font_size
        )
    end

    #
    df_ref = filter(
        :idx_path => n -> n == 1,
        df_mc
    )

    # Stock
    ref_line = lines!(
        axtop,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )
    i = 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    lines!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :K_stock],
        color=color_ref
    )

    lines!(
        axtop,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :K_stock],
        color=color_ref
    )

    band_ = band!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :K_stock],
        pop_size * df_upper_q[!, :K_stock],
        alpha=0.3
    )

    lines!(
        axtop,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )
    med_line = lines!(
        axtop,
        df_median[!, :time],
        pop_size * df_median[!, :K_stock],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)
    lines!(
        axtop,
        df_median[!, :time],
        pop_size * df_median[!, :K_stock],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    # Vaccination rate
    lines!(
        axmidle,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :action],
        color=color_ref
    )

    lines!(
        axmidle,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :action],
        color=color_ref
    )

    band!(
        axmidle,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :action],
        pop_size * df_upper_q[!, :action],
        alpha=0.3
    )

    lines!(
        axmidle,
        df_ref[!, :time],
        pop_size * df_ref[!, :action],
        color=color_ref
    )

    lines!(
        axmidle,
        df_median[!, :time],
        pop_size * df_median[!, :action],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)


    # Symtomatic Infected class
    lines!(
        axright,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :I_S],
        color=color_ref,
        label="Reference"
    )

    lines!(
        axright,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        color=color_ref
    )

    band!(
        axright,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        pop_size * df_upper_q[!, :I_S],
        alpha=0.3,
        label="CI 95%"
    )

    lines!(
        axright,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_S],
        color=color_ref
    )

    lines!(
        axright,
        df_median[!, :time],
        pop_size * df_median[!, :I_S],
        color=color_m,
        label="median"
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    # Counter plot
    descision = df_mc[!, :opt_policy]
    df_descision = DataFrame(opt_policy=descision)
    df_descision_01 = df_descision[
        (df_descision.opt_policy.==0.0).|(df_descision.opt_policy.==1.0),
        :]


    count_opt_decs = countmap(df_descision_01[!, :opt_policy])
    barplot!(
        axbottom,
        collect(keys(count_opt_decs)),
        collect(values(count_opt_decs)),
        strokecolor=:black,
        strokewidth=2,
        #colormap =colors[1:size(collect(keys(count_opt_decs)))[1]]
        # color=[:red, :orange, :azure, :brown]
        color=[:red, :azure]
    )
    #= l = Legend(
        f[4, 1:2, Top()],
        [ref_line, med_line, band_],
        ["reference path", "median", "95% Conf."]
    )

    l.orientation = :horizontal
    =#
    i = i + 1
    axislegend(
        axright,
        merge=true,
        unique=true,
        position=:rb,
        nbanks=2,
        rowgap=10,
        orientation=:horizontal
    )
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f, px_per_unit=10)
    filename = file_name * ".png"
    save(filename, f, px_per_unit=10)
    return f
end
"""
Returns a figure that encloses a panel visualization with 
the confidence bands from quartiles 0.5 and .95 for the:
epidemic states.

# Arguments
- `df_lower_q::DataFrame`: 
- `df_median::DataFrame`:
- `df_upper_q::DataFrame`:
- `df_ref::DataFrame`: DataFrame with the opt_Policy col from MonteCarlo Sampling 
- `pop_size::Float64`:
- `file_name::AbstractString`:
"""

function get_epidemic_states_confidence_bands(
    df_lower_q::DataFrame,
    df_median::DataFrame,
    df_upper_q::DataFrame,
    df_mc::DataFrame,
    pop_size::Float64,
    file_name::AbstractString
)
    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 190
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f = 72.0 .* size_inches

    f = Figure(
        resolution=size_pt_f,
        fontsize=12
    )

    # colors
    # color_q = (:azure, 1.0)
    color_m = (:orange, 0.4)
    color_ref = (:grey0, 1.0)
    axtop = Axis(
        f[1, 1],
        ylabel=L"I_S"
    )
    axmidle_0 = Axis(
        f[2, 1],
        ylabel=L"D"
    )
    axmidle_1 = Axis(
        f[3, 1],
        ylabel=L"V"
    )
    axbottom = Axis(
        f[4, 1],
        xlabel="time (day)",
        ylabel=L"X_{VAC}"
    )
    #
    df_ref = filter(
        :idx_path => n -> n == 1,
        df_mc
    )
    hidexdecorations!(axtop, grid=false)
    hidexdecorations!(axmidle_0, grid=false)
    hidexdecorations!(axmidle_1, grid=false)
    axs = [axtop, axmidle_0, axmidle_1, axbottom]
    labels = ["(A)", "(B)", "(C)", "(D)"]
    font_size = 18
    hv_offset = (4, -1)

    for (ax, label) in zip(axs, labels)
        text!(
            ax,
            0, 1,
            text=label,
            font=:bold,
            align=(:left, :top),
            offset=hv_offset,
            space=:relative,
            fontsize=font_size
        )
    end

    # Symptomatics

    lines!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        color=color_ref
    )

    lines!(
        axtop,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :I_S],
        color=color_ref
    )

    band!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        pop_size * df_upper_q[!, :I_S],
        alpha=0.3,
        label="CI 95%"
    )

    lines!(
        axtop,
        df_median[!, :time],
        pop_size * df_median[!, :I_S],
        color=color_m,
        label="median"
    )

    # Deaths
    lines!(
        axmidle_0,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :D],
        color=color_ref
    )

    lines!(
        axmidle_0,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :D],
        color=color_ref
    )

    band!(
        axmidle_0,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :D],
        pop_size * df_upper_q[!, :D],
        alpha=0.3
    )

    lines!(
        axmidle_0,
        df_median[!, :time],
        pop_size * df_ref[!, :D],
        color=color_m
    )

    # Vaccinated
    lines!(
        axmidle_1,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :V],
        color=color_ref
    )

    lines!(
        axmidle_1,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :V],
        color=color_ref
    )

    band!(
        axmidle_1,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :V],
        pop_size * df_upper_q[!, :V],
        alpha=0.3
    )

    lines!(
        axmidle_1,
        df_median[!, :time],
        pop_size * df_median[!, :V],
        color=color_m
    )


    # Coverage
    df_q_low_x_cov = 100.0 * df_lower_q[!, :X_vac]
    df_q_up_x_cov = 100.0 * df_upper_q[!, :X_vac]
    df_q_med_x_cov = 100.0 * df_median[!, :X_vac]

    lines!(
        axbottom,
        df_lower_q[!, :time],
        df_q_low_x_cov,
        color=color_ref
    )

    lines!(
        axbottom,
        df_upper_q[!, :time],
        df_q_up_x_cov,
        color=color_ref
    )

    band!(
        axbottom,
        df_lower_q[!, :time],
        df_q_low_x_cov,
        df_q_up_x_cov,
        alpha=0.3
    )

    lines!(
        axbottom,
        df_median[!, :time],
        df_q_med_x_cov,
        color=color_m
    )

    axislegend(
        axtop,
        merge=true,
        unique=true,
        position=:rb,
        orientation=:horizontal
    )
    filename = file_name
    save(filename, f)
    f
end

"""
Returns two figure that encloses a the visualization of
the reference deterministic path with the evolution of the
dynamic model and the regarding policy. 

# Arguments
- `df_mc::DataFrame`: DataFrame with the opt_Policy col from MonteCarlo sampling
- `pop_size::Float64`:
- `file_name_f1::AbstractString`:
- `file_name_f2::AbstractString`:
"""

function get_deterministic_plot_path(
    df_mc::DataFrame,
    pop_size::Float64,
    file_name_f1::AbstractString,
    file_name_f2::AbstractString)
    #
    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 180
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f1 = 72.0 .* size_inches
    font_size = 18
    hv_offset = (4, -1)

    f1 = Figure(
        resolution=size_pt_f1,
        fontsize=12
    )
    # colors
    f2 = Figure(
        resolution=size_pt_f1,
        fontsize=12
    )
    color_ref = (:grey0, 1.0)
    ax_top_1_f1 = Axis(
        f1[1, 1],
        ylabel=L"$K_t$ (No. doses)"
    )
    ax_bottom_1_f1 = Axis(
        f1[2, 1],
        ylabel=L"$\psi_V^{(k)}$ (doses/day)",
        xlabel="time (day)"
    )

    ax_top_1_f2 = Axis(
        f2[1, 1],
        ylabel=L"S"
    )
    ax_top_2_f2 = Axis(
        f2[1, 2],
        ylabel=L"E"
    )
    ax_top_3_f2 = Axis(
        f2[1, 3],
        ylabel=L"I_S"
    )

    ax_bottom_1_f2 = Axis(
        f2[2, 1],
        ylabel=L"I_A",
        xlabel="time (day)"
    )
    ax_bottom_2_f2 = Axis(
        f2[2, 2],
        ylabel=L"V",
        xlabel="time (day)"
    )
    ax_bottom_3_f2 = Axis(
        f2[2, 3],
        ylabel=L"Coverage $X_{VAC}$",
        xlabel="time (day)"
    )

    axs = [
        ax_top_1_f1,
        ax_bottom_1_f1,
        ax_top_1_f2,
        ax_top_2_f2,
        ax_top_3_f2,
        ax_bottom_1_f2,
        ax_bottom_2_f2,
        ax_bottom_3_f2
    ]
    labels = ["(A)", "(B)", "(A)", "(B)", "(C)", "(D)", "(E)", "(F)"]
    font_size = 18
    hv_offset = (4, -1)

    for (ax, label) in zip(axs, labels)
        text!(
            ax,
            0, 1,
            text=label,
            font=:bold,
            align=(:left, :top),
            offset=hv_offset,
            space=:relative,
            fontsize=font_size
        )
    end

    #
    df_ref = filter(
        :idx_path => n -> n == 1,
        df_mc
    )
    hidexdecorations!(ax_top_1_f1, grid=false)
    hidexdecorations!(ax_top_1_f2, grid=false)
    hidexdecorations!(ax_top_2_f2, grid=false)
    hidexdecorations!(ax_top_3_f2, grid=false)

    # Stock-Vaccination Rate

    lines!(
        ax_top_1_f1,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )

    lines!(
        ax_bottom_1_f1,
        df_ref[!, :time],
        pop_size * df_ref[!, :action],
        color=color_ref
    )

    # Epidemic states

    lines!(
        ax_top_1_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :S],
        color=color_ref
    )

    lines!(
        ax_top_2_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :E],
        color=color_ref
    )

    lines!(
        ax_top_3_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_S],
        color=color_ref
    )

    lines!(
        ax_bottom_1_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_A],
        color=color_ref
    )

    lines!(
        ax_bottom_2_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :D],
        color=color_ref
    )

    lines!(
        ax_bottom_3_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :X_vac],
        color=color_ref
    )

    #= l = Legend(
        f[5, 1, Top()],
        [med_line, band_],
        ["median", "95% Conf."]
    )

    l.orientation = :horizontal
    =#
    filename_f1 = file_name_f1
    filename_f2 = file_name_f2
    save(filename_f1, f1)
    save(filename_f2, f2, px_per_unit=10)
    return f1, f2
end

#=
Debugger.@enter montecarlo_sampling(
    10000,
    "./data/parameters_model.json"
)
=#
montecarlo_sampling(
    10000,
    "./data/parameters_model.json"
)