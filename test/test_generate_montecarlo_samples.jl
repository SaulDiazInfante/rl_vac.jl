using rl_vac
using DataFrames, CSV, JSON
using Debugger
sampling_size = 3

df_mc = DataFrame()
df_args_initial_condition = DataFrame()
df_args_inventory_parameters = DataFrame()
args = build_testing_parameters()
initial_condition = copy(args["initial_condition"])
inventory_parameters = copy(args["inventory_parameters"])
sol = get_solution_path!(args)
# Debugger.@enter get_solution_path!(args)
df_sol = save_solution_path(sol)
df_sol.idx_path = fill(0, nrow(df_sol))
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


df_mc = [df_mc; df_sol]
df_args_initial_condition = [df_args_initial_condition; df_initial_condition]
df_args_inventory_parameters = [
    df_args_inventory_parameters;
    df_inventory_parameters
]

n = sampling_size
copy_args = copy(args)

for idx in 1:sampling_size
    copy_args = build_testing_parameters()
    get_stochastic_perturbation!(copy_args)
    sol = get_solution_path!(copy_args)
    df_sol = save_solution_path(sol)
    df_sol.idx_path = fill(idx, nrow(df_sol))

    df_inventory_parameters = save_inventory_parameters_to_json(
        args["inventory_parameters"],
        "data/inventory_parameters_$(idx).json"
    )
    df_inventory_parameters.idx_path = fill(
        idx,
        nrow(df_inventory_parameters)
    )
    df_initial_condition = save_state_to_json(
        args["initial_condition"],
        "data/initial_condition_$(idx).json"
    )
    df_initial_condition.idx_path = fill(
        idx,
        nrow(df_initial_condition)
    )

    df_mc = [df_mc; df_sol]
    df_args_initial_condition = [
        df_args_initial_condition;
        df_initial_condition
    ]
    df_args_inventory_parameters = [
        df_args_inventory_parameters;
        df_inventory_parameters
    ]
end
unique(df_mc.idx_path)
CSV.write("data/df_mc.csv", df_mc)
CSV.write("data/df_initial_condition.csv", df_args_initial_condition)
CSV.write("data/df_inventory_parameters.csv", df_args_inventory_parameters)

