"""
    get_initial_condition(parameters::DataFrame) -> DataFrame

Generate the initial condition for a simulation based on the provided parameters.

# Arguments
- `parameters::DataFrame`: A DataFrame containing the initial values for various compartments 
  and parameters required for the simulation. The expected columns include:
  - `S_0`: Initial susceptible population.
  - `E_0`: Initial exposed population.
  - `I_S_0`: Initial symptomatic infected population.
  - `I_A_0`: Initial asymptomatic infected population.
  - `R_0`: Initial recovered population.
  - `D_0`: Initial deceased population.
  - `V_0`: Initial vaccinated population.
  - `X_0_mayer`: Initial value for the Mayer state variable.
  - `T`: Initial temperature parameter.
  - `delivery_size_k`: Initial stock size.
  - `N`: Total population size.

# Returns
- `DataFrame`: A DataFrame containing the initial state of the system, with the following columns:
  - `"time"`: Initial time (set to 0.0).
  - `"S"`: Susceptible population.
  - `"E"`: Exposed population.
  - `"I_S"`: Symptomatic infected population.
  - `"I_A"`: Asymptomatic infected population.
  - `"R"`: Recovered population.
  - `"D"`: Deceased population.
  - `"V"`: Vaccinated population.
  - `"CL"`: Cumulative population size.
  - `"X_vac"`: Initial value for the vaccination state variable (set to 0.0).
  - `"X_0_mayer"`: Initial value for the Mayer state variable.
  - `"K_stock_t"`: Normalized stock size after the first delivery.
  - `"T"`: Temperature parameter.
  - `"loss"`: Initial loss value (set to 0.0).
  - `"action"`: Initial action value (set to 0.0).
  - `"opt_policy"`: Initial optimal policy indicator (set to 1.0).
  - `"t_interval_idx"`: Initial time interval index (set to 1).

# Notes
- The function calculates the cumulative population size (`CL0`) as the sum of all initial compartments.
- The stock size (`k_0`) is normalized by dividing the initial stock size (`delivery_size_k`) by the total population size (`N`).
"""
function get_initial_condition(parameters::DataFrame)
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
    k_0 = parameters.delivery_size_k[1] / parameters.N[1]
    CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
    header_str = [
        "time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "X_0_mayer", "K_stock_t",
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
    return x_0
end