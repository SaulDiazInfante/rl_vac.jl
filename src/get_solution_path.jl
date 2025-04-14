"""
    get_solution_path!(parameters::DataFrame)
    Compute a path of the solution process
# Arguments
- `parameters::DataFrame: Current values for model parameters and 
    simulation configuration.
...
"""
function get_solution_path!(args::Dict{String,Any})::DataFrame

    args = build_testing_parameters()
    initial_condition = args["initial_condition"]
    state = args["state"]
    model_parameters = args["model_parameters"]
    numeric_solver_parameters = args["numeric_solver_parameters"]
    inventory_parameters = args["inventory_parameters"]

    N_grid_size = numeric_solver_parameters.N_grid_size
    pop_size = model_parameters.N
    list_solution = []
    df_solution = DataFrame()
    prior_inventory = 0.0
    initial_condition_at_stage_k = get_struct_values(initial_condition)




    for t in range(1, length(parameters.t_delivery) - 1)
        normalized_delivery_size_at_stake_k = (
            parameters.delivery_size_k[t] / parameters.N[1]
        )
        current_inventory_size = prior_inventory +
                                 normalized_delivery_size_at_stake_k
        next_delivery_time = parameters.t_delivery[t+1]
        current_delivery_time = parameters.t_delivery[t]
        h = (
            next_delivery_time -
            current_delivery_time
        ) / N_grid_size
        time_interval_k = LinRange(
            current_delivery_time + h,
            next_delivery_time,
            N_grid_size
        )
        vaccine_coverage = get_vaccine_stock_coverage(args)
        vaccination_rate = get_max_vaccination_rate!() |

        opt_solution_t = optimize_interval_solution(
            time_interval_k,
            args
        )
        list_solution = push!(list_solution, opt_solution_t)
        prefix = "df_solution_"
        suffix = "$(t)" * ".csv"
        file = "./data/" * prefix * suffix
        df_solution_t = save_interval_solution(
            opt_solution_t;
            file_name=file
        )
        df_solution = [df_solution; df_solution_t]

        x_t_0_k = df_solution_t[end, 1:17]
        initial_condition_at_stage_k = DataFrame(x_t_0_k)
        prior_inventory = x_t_0_k.K_stock_t
    end
    CSV.write("./data/df_solution.csv", df_solution)
    return x_0, df_solution
end