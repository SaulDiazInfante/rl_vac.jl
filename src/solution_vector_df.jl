function solution_vector_df(x_t::DataFrame)
    t = x_t.time[1]
    S_0 = x_t.S[1]
    E_0 = x_t.E[1]
    I_S_0 = x_t.I_S[1]
    I_A_0 = x_t.I_A[1]
    R_0 = x_t.R[1]
    D_0 = x_t.D[1]
    V_0 = x_t.V[1]
    X_0_mayer_0 = x_t.X_0_mayer[1]
    X_vac_0 = x_t.X_vac[1]
    k_0 = x_t.K_stock[1]
    CL0 = x_t.CL[1]
    T_0_k = x_t.T[1]
    loss = 0.0
    x_vec = [
        t, S_0, E_0,
        I_S_0, I_A_0, R_0,
        D_0, V_0, CL0,
        X_vac_0, X_0_mayer_0, k_0,
        T_0_k, loss, a_t,
        opt_policy, index
    ]

    header_str = [
        "time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock",
        "T", "loss", "action",
        "opt_policy", "t_index_interval"
    ]
    df_sol = DataFrame(
        Dict(
            zip(
                header_str,
                x_vec
            )
        )
    )

end