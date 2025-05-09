"""
    montecarlo_sampling(; sampling_size=10000)

Performs Monte Carlo sampling to generate simulation data and saves the results to CSV files.

# Arguments
- `sampling_size::Int=10000`: The number of Monte Carlo samples to generate. Defaults to 10,000.

# Description
This function performs the following steps:
1. Initializes the simulation setup by calling `setup_mc_simulation()`.
2. Iteratively generates `sampling_size` solution paths by:
   - Building testing parameters.
   - Applying stochastic perturbations.
   - Solving the simulation path.
   - Saving the solution path, inventory parameters, and initial conditions to data frames.
3. Appends the generated data to cumulative data frames for Monte Carlo samples, initial conditions, and inventory parameters.
4. Writes the cumulative data frames to CSV files in the `data/` directory.
5. Tags the generated files with metadata and prints the tagged file paths.

# Outputs
The function generates and saves the following CSV files:
- `data/df_mc.csv`: Contains the Monte Carlo simulation results.
- `data/df_initial_condition.csv`: Contains the initial condition parameters for each sample.
- `data/df_inventory_parameters.csv`: Contains the inventory parameters for each sample.

# Notes
- The function uses a progress bar (`Progress`) to indicate the sampling progress.
- The `tag_file` function is used to add metadata to the generated files.
"""
function generate_montecarlo_samples(
    sampling_size=10000
)
    df_mc,
    df_args_initial_condition,
    df_args_inventory_parameters,
    args = setup_mc_simulation()

    n = sampling_size
    p = Progress(n, 1, "Sampling")
    copy_args = copy(args)

    data_dir = joinpath(dirname(@__DIR__), "data/mc_sampling")
    path_mc = joinpath(data_dir, "monte_carlo_paths.csv")
    # path_initial_condition = joinpath(data_dir, "initial_conditions.csv")
    path_inventory_parameters = joinpath(data_dir, "inventory_parameters.csv")
    for idx in 1:sampling_size
        sol = get_solution_path!(copy_args)
        df_sol = save_solution_path(sol)
        df_sol.idx_path = fill(idx, nrow(df_sol))
        CSV.write(path_mc, df_sol; append=true, writeheader=(idx == 1))
        df_mc = vcat(df_mc, df_sol)

        copy_args = build_testing_parameters()
        get_stochastic_perturbation!(copy_args)

        df_inventory_parameters = save_inventory_parameters_to_json(
            copy_args["inventory_parameters"],
            "data/inventory_parameters_.json"
        )
        df_inventory_parameters.idx_path = fill(
            idx,
            nrow(df_inventory_parameters)
        )
        CSV.write(
            path_inventory_parameters,
            df_inventory_parameters;
            append=true, writeheader=(idx == 1)
        )
        df_args_inventory_parameters = vcat(
            df_args_inventory_parameters,
            df_inventory_parameters
        )
        next!(p)
    end


    cvs_prefix_file_names = [
        "df_mc",
        "df_initial_condition",
        "df_inventory_parameters"
    ]
    dfs = [df_mc, df_args_initial_condition, df_args_inventory_parameters]

    for (file_name, df) in zip(cvs_prefix_file_names, dfs)
        df_tag_args = Dict(
            "path" => data_dir,
            "prefix_file_name" => file_name,
            "suffix_file_name" => ".csv"
        )
        df_tag = tag_file(df_tag_args)
        CSV.write(df_tag, df)
    end
end