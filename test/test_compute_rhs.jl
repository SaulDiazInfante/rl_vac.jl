using rl_vac

initial_condition_path = "./data/initial_condition.json"
model_parameters_path = "./data/model_parameters.json"
numeric_solver_parameters_path = "./data/numeric_solver_parameters.json"
inventory_parameters_path = "./data/inventory_parameters.json"

initial_condition = json_to_struct(structState, initial_condition_path)
current_state = json_to_struct(structState, initial_condition_path)
model_par = json_to_struct(structModelParameters, model_parameters_path)
numeric_solver_par = json_to_struct(
    structNumericSolverParameters,
    numeric_solver_parameters_path
)
inventory_par = json_to_struct(
    structInventoryParameters, inventory_parameters_path
)


args = Dict(
    "initial_condition" => initial_condition,
    "state" => current_state,
    "model_parameters" => model_par,
    "numeric_solver_parameters" => numeric_solver_par,
    "inventory_parameters" => inventory_par
)
rhs_evaluation!(
    args
)

