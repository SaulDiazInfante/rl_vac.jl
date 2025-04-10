"""
    build_testing_parameters() -> Dict{String, Any}

Builds and returns a dictionary containing testing parameters for a simulation or model. 
The function reads JSON files containing initial conditions, model parameters, numeric 
solver parameters, and inventory parameters, converts them into corresponding Julia 
structures, and organizes them into a dictionary.

# Returns
- `Dict{String, Any}`: A dictionary with the following keys:
    - `"initial_condition"`: The initial condition structure loaded from JSON.
    - `"state"`: A copy of the initial condition structure representing the current state.
    - `"model_parameters"`: The model parameters structure loaded from JSON.
    - `"numeric_solver_parameters"`: The numeric solver parameters structure loaded from JSON.
    - `"inventory_parameters"`: The inventory parameters structure loaded from JSON.

# Notes
- The function assumes the existence of specific JSON files in the `../data/` directory 
  relative to the source file's location.
- The `json_to_struct` function is used to parse JSON files into Julia structures. 
  Ensure that the corresponding structures (`structState`, `structModelParameters`, 
  `structNumericSolverParameters`, `structInventoryParameters`) are defined elsewhere 
  in the codebase.
"""
function build_testing_parameters()
    parameters_paths = Dict(
        "initial_condition" => "../data/initial_condition.json",
        "model_parameters" => "../data/model_parameters.json",
        "numeric_solver_parameters" => "../data/numeric_solver_parameters.json",
        "inventory_parameters" => "../data/inventory_parameters.json"
    )

    initial_condition_path = joinpath(
        @__DIR__,
        parameters_paths["initial_condition"]
    )

    model_parameters_path = joinpath(
        @__DIR__, parameters_paths["model_parameters"]
    )
    numeric_solver_parameters_path = joinpath(
        @__DIR__,
        parameters_paths["numeric_solver_parameters"]
    )
    inventory_parameters_path = joinpath(
        @__DIR__,
        parameters_paths["inventory_parameters"]
    )

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
    return args
end