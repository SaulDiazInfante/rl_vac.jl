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
    temperature_T = parameters.T[1]
    # normalized stock size after first delivery
    k_0 = parameters.k_stock[1] / parameters.N[1]
    operational_levels = parameters.operational_stock_levels
    CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
    header_str = [
        "time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer","K_stock",
        "T", "loss", "action",
        "opt_policy", "t_interval_idx"
    ]
    
    x_0_vector = [
        0.0, S_0, E_0,
        I_S_0, I_A_0, R_0, 
        D_0, V_0, CL0,
        X_vac_0, X_0_mayer, k_0, 
        temperature_T, 0.0, 0.0,
        1.0, 1
    ]
    x_0 = DataFrame(
        Dict(
            zip(
                header_str,
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
    # determine the best course of action.
    # We begin by considering the number of calculated jabs needed to
    # achieve the desired vaccine coverage. 
    
    a_t = get_vaccine_action!(X_C, t_delivery_1, parameters)
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
    for rho_k in operational_levels[1:(end - 1)]
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
        if cost <=  opt_cost
            opt_cost = cost
            candidate_solution = solution_1
            opt_policy = policy
        end
    end
    opt_solution_1 = candidate_solution
    prefix = "df_solution_"
    suffix = "1.csv"
    file = "./data/" * prefix * suffix
    df_solution_1 =
    save_interval_solution(
        opt_solution_1;
        file_name = file
    )
    solution_list =[]
    solution_list = push!(solution_list, df_solution_1)
    df_solution = DataFrame()
    df_solution = [df_solution; df_solution_1]
    #
    # Solution on each t_interval
    
    for t in 2:(length(parameters.t_delivery) - 1)
        h = (parameters.t_delivery[t + 1] -
            parameters.t_delivery[t]) / N_grid_size
        t_interval =
            LinRange(
                parameters.t_delivery[t] +
                h,
                parameters.t_delivery[t+1],
                N_grid_size
        )
        # initial condition for left bound interval
        x_t_0_k = solution_list[t-1][end, :]
        x_t_0_k = DataFrame(x_t_0_k)
        # updating the current stock with the kth-delivery
        k_t_0_k = x_t_0_k.K_stock[1] + parameters.k_stock[t] / parameters.N[t]
        parameters.X_vac_interval[t] = x_t_0_k.X_vac[1]
        X_Ct = get_vaccine_stock_coverage(k_t_0_k, parameters)
        t_delivery_t = parameters.t_delivery[t + 1]
        # TODO: Code the implementation for a sequential decision
        a_t = get_vaccine_action!(X_Ct, t_delivery_t, parameters)
        ## Optimal Decision
        opt_policy = operational_levels[end]
        solution_t = get_interval_solution!(
            t_interval,
            x_t_0_k,
            opt_policy,
            a_t,
            k_t_0_k,
            parameters
        )
        ### optimization by exhaustive search
        candidate_solution = solution_t
        opt_cost = candidate_solution[end, 11]
        for rho_k in operational_levels[1:(end-1)]
            policy = rho_k
            solution_t = get_interval_solution!(
                t_interval,
                x_t_0_k,
                policy,
                a_t,
                k_t_0_k,
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
        suffix = "$(t)"*".csv"
        file = "./data/" * prefix * suffix
        df_solution_t = 
            save_interval_solution(
                opt_solution_t; 
                file_name = file
        )
        solution_list = push!(solution_list, df_solution_t)
        df_solution = [df_solution; df_solution_t]
    end
    CSV.write("./data/df_solution.csv", df_solution)
    return x_0, df_solution
end