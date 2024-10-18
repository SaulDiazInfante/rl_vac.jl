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
    sol = zeros(Float64, N_grid_size, 14)

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
        a_t, opt_policy
    ]

    sol[1, :] = x_00
    header_strs = [
        "t",
        "S", "E", "I_S",
        "I_A", "R", "D",
        "V", "CL", "X_vac",
        "X_0_mayer", "K_stock", "action",
        "opt_policy"
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
