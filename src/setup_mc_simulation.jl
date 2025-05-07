"""
    setup_mc_simulation()

Sets up the Monte Carlo simulation by preparing data frames and parameters.

# Returns
- `df_monte_carlo::DataFrame`: An empty DataFrame for Monte Carlo results.
- `df_args_initial_condition::DataFrame`: DataFrame containing initial condition arguments.
- `df_args_inventory_parameters::DataFrame`: DataFrame containing inventory parameter arguments.
- `args::Dict`: Dictionary of testing parameters.
"""
function setup_mc_simulation()

    df_monte_carlo = DataFrame()
    df_args_initial_condition = DataFrame()
    df_args_inventory_parameters = DataFrame()
    args = build_testing_parameters()
    initial_condition = copy(args["initial_condition"])
    inventory_parameters = copy(args["inventory_parameters"])

    df_inventory_parameters = save_inventory_parameters_to_json(
        inventory_parameters,
        "data/inventory_parameters_ref.json"
    )
    df_inventory_parameters.idx_path = fill(0, nrow(df_inventory_parameters))
    df_initial_condition = save_state_to_json(
        initial_condition,
        "data/initial_condition_ref.json"
    )
    df_initial_condition.idx_path = fill(0, nrow(df_initial_condition))

    df_args_initial_condition = vcat(
        df_args_initial_condition,
        df_initial_condition
    )
    df_args_inventory_parameters = vcat(
        df_args_inventory_parameters,
        df_inventory_parameters
    )
    args
    return df_monte_carlo, df_args_initial_condition, df_args_inventory_parameters, args
end