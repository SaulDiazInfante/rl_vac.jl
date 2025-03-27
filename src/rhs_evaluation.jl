"""
        rhs_evaluation!(
                t::Float64,
                x::DataFrame,
                opt_policy::Float64,
                a_t::Float64,
                k,
                parameters::DataFrame
        )::Vector{Float64}

Approximate the solution to `SEIRVDX_vac`` ODE by returning an array with
the right-hand side evaluation of The Non-Standard recurrence; refer to
the corresponding article for formulation.

# Arguments
- `t::Float64`: time 
- `x::DataFrame`: System current state
- `a_t::Float64`: action, that is a proportion of the total jabs projected
  that would be administrated,
- `k::Float64`: current vaccine stock, 
- `parameters::DataFrame`: current parameters.
...
"""
function rhs_evaluation!(
        t::Float64,
        x::DataFrame,
        opt_policy,
        a_t::Float64,
        k::Float64,
        parameters::DataFrame
)::Vector{Float64}

        x_new = zeros(17)
        reserve_inventory = parameters.low_stock[1] / parameters.N[1]
        index = get_stencil_projection(x.time[1], parameters)
        n_deliveries = size(parameters.t_delivery, 1)
        if (index >= n_deliveries)
                print("WARNING: simulation time OverflowErr")
        end

        X_vac_interval = parameters.X_vac_interval[index]
        x_new = compute_nsfd_iteration!(
                t,
                x,
                opt_policy,
                a_t,
                k,
                parameters
        )

        CL_new = sum(x_new[2:8])
        if !isapprox(CL_new, 1.0; atol=1e-12, rtol=0)
                print("\n (----) WARNING: Conservative low overflow")
        end
        X_vac_new = x_new[10]

        sign_effective_stock =
                sign(
                        k - (X_vac_new - X_vac_interval) - reserve_inventory
                )
        sign_effective_stock_test = (sign_effective_stock < 0.0)

        if sign_effective_stock_test
                # Recalibrate the vaccine coverage and vaccination rate
                print("\n(===) WARNING: reserve vaccine inventory overflow")
                print("\n(+++) Recalibrating the vaccination rate: ")
                current_stock = x[!, "K_stock"][1]
                vaccine_coverage = max(0.0, current_stock - reserve_inventory)
                T_index = get_stencil_projection(x.time[1], parameters)
                t_lower_interval = x.time[1]
                t_upper_interval = parameters.t_delivery[T_index+1]
                length_interval = t_upper_interval - t_lower_interval
                psi_v = -log(1.0 - vaccine_coverage) / length_interval
                a_t = max(0.0, psi_v)
                parameters.psi_v[index] = psi_v
                projected_jabs = vaccine_coverage
                N_pop = parameters.N[1]
                scaled_psi_v = psi_v * N_pop
                msg_01 = "\n\t normalized Psi_V: $(@sprintf("%.8f", psi_v))"
                msg_02 = "\n\t nominal Psi_V: $(
                                @sprintf("%.8f", scaled_psi_v
                        )
                )"
                print("\n===========================================")
                print("\nt_lower: ", x.time[1])
                print("\nt_upper: ", t_upper_interval)
                print("\n length_interval: ", length_interval)
                print(msg_01)
                print(msg_02)
                print("\nActual stock: ", current_stock * N_pop)
                print("\n\tProjected Jabs: $(
                                @sprintf("%4.2f", projected_jabs * N_pop)
                        )
                ")
                print("\n-------------------------------------------\n")
                x_new = compute_nsfd_iteration!(
                        t,
                        x,
                        opt_policy,
                        a_t,
                        k,
                        parameters
                )
        end
        return x_new
end
