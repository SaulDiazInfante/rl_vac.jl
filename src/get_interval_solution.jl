"""
    get_interval_solution!(
        time_interval, x, opt_policy, action_t, k, parameters
    )::Matrix{Float64}

Generate the values of all compartments for points of a given interval time 

# Arguments
- `time_interval::LinRange{Float64, Int64}`: Interval time.
- `x::DataFrame`: System current state.
- `opt_policy::Float`: Optimal level of vaccine inventory coverage. 
- `action_t::Float`: Action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: Normalized size order of the vaccine delivery .
- `parameters::DataFrame`: Current parameters.
...
"""
function get_interval_solution!(par::Dict...)::Matrix{Float64}

    t_0 = par.time_interval[1]
    index = get_stencil_projection(t_0, par.parameters)
    N_grid_size = par.parameters.N_grid_size[index]
    sol = zeros(Float64, N_grid_size, 17)

    S_0 = par.x_zero_k.S[1]
    E_0 = par.x_zero_k.E[1]
    I_S_0 = par.x_zero_k.I_S[1]
    I_A_0 = par.x_zero_k.I_A[1]
    R_0 = par.x_zero_k.R[1]
    D_0 = par.x_zero_k.D[1]
    V_0 = par.x_zero_k.V[1]
    X_0_mayer_0 = par.x_zero_k.X_0_mayer[1]
    X_vac_0 = par.x_zero_k.X_vac[1]
    current_stock_size = par.x_zero_k.K_stock_t[1]
    action_t = par.x_zero_k.action[1]
    opt_policy = par.x_zero_k.opt_policy[1]
    CL0 = par.x_zero_k.CL[1]
    T_0_k = par.x_zero_k.T[1]
    loss = 0.0
    x_00 = [
        t_0, S_0, E_0,
        I_S_0, I_A_0, R_0,
        D_0, V_0, CL0,
        X_vac_0, X_0_mayer_0, current_stock_size,
        T_0_k, loss, action_t,
        opt_policy, index
    ]

    sol[1, :] = x_00
    header_str = [
        "time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock_t",
        "T", "loss", "action",
        "opt_policy", "t_index_interval"
    ]
    for j = 2:N_grid_size
        #x_new = rhs_evaluation(x_old, parameters)
        S_old = sol[j-1, :]
        S_old_df = DataFrame(
            Dict(
                zip(
                    header_str,
                    S_old
                )
            )
        )
        t = par.time_interval[j]
        par = Dict(
            :t => t,
            :x => S_old_df,
            :parameters => par.parameters
        )
        sol[j, :] = rhs_evaluation!(; par...)
    end
    return sol
end
