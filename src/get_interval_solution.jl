"""
    get_interval_solution!(
        time_interval, x, opt_policy, a_t, k, parameters
    )::Matrix{Float64}

Generate the values of all compartments for points of a given interval time 

# Arguments
- `time_interval::LinRange{Float64, Int64}`: Interval time.
- `x::DataFrame`: System current state.
- `opt_policy::Float`: Optimal level of vaccine inventory coverage. 
- `a_t::Float`: Action, that is a proportion of the total jabs projected
  that would be administrated.
- `parameters::DataFrame`: Current parameters.
...
"""
function get_interval_solution!(
    time_interval::LinRange{Float64, Int64},
    x::DataFrame,
    opt_policy::Float64,
    a_t::Float64,
    k::Float64,
    parameters::DataFrame
)::Matrix{Float64}
    t_0 = time_interval[1]
    index = get_stencil_projection(t_0, parameters)
    N_grid_size = parameters.N_grid_size[index]
    sol = zeros(Float64, N_grid_size, 17)

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
    T_0_k = -70.0
    loss = 0.0
    x_00 = [
        t_0, S_0, E_0,
        I_S_0, I_A_0, R_0,
        D_0, V_0, CL0,
        X_vac_0, X_0_mayer_0, k_0,
        T_0_k, loss, a_t,
        opt_policy, index
    ]

    sol[1, :] = x_00
    header_str = [
        "t", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
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
        t = time_interval[j]
        sol[j, :] = rhs_evaluation!(t, S_old_df, opt_policy, a_t, k, parameters)
    end
    return sol
end
