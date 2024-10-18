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

    N_grid_size = parameters.N_grid_size[1];
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
        "X_vac", "X_0_mayer","K_stock", 
        "action", "opt_policy"
    ]
    x_0= [
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