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
function rhs_evaluation!(t, x, opt_policy, a_t, k, parameters)
        #TODO: Check dimesions with other scripts
        x_new = zeros(14)
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
                msg_02 = "\n\t normalized Psi_V: $(
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
                                        + alpha_a * I_A_new
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
        return x_new
end
