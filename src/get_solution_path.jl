"""
    get_solution_path!(args::Dict{String,Any})::Vector{Matrix{Real}}

Computes the solution path for a given set of arguments by iteratively optimizing the stage solutions 
based on vaccine stock coverage and vaccination rates. The function modifies the input arguments 
in-place and returns a list of matrices representing the solution path.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"initial_condition"`: The initial state of the system.
  - `"state"`: The current state of the system.
  - `"model_parameters"`: Parameters defining the model.
  - `"numeric_solver_parameters"`: Parameters for the numerical solver.
  - `"inventory_parameters"`: Parameters related to inventory management.

# Returns
- `Vector{Matrix{Real}}`: A vector of matrices, where each matrix represents the solution at a specific stage.

# Workflow
1. Processes the first inventory reorder point and initializes the state and parameters.
2. Computes the vaccine stock coverage and determines the maximum vaccination rate.
3. Optimizes the stage solution and appends it to the solution list.
4. Iterates through the reorder time points, updating the state and optimizing the stage solution at each point.
5. Returns the list of stage solutions.

# Notes
- The function assumes that `time_reorder_points` is defined in the scope and contains the time points for inventory reordering.
- The function modifies the `args` dictionary in-place, updating the `"state"` and `"initial_condition"` keys.
"""

function get_solution_path!(args::Dict{String,Any})::Vector{Matrix{Real}}
    process_first_inventory_reorder_point!(args)
    inventory_parameters = copy(args["inventory_parameters"])
    solution_list = Matrix{Real}[]

    vaccine_coverage = get_vaccine_stock_coverage(args)
    vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
    args["state"].action = vaccination_rate
    args["initial_condition"].action = vaccination_rate
    stage_solution = optimize_stage_solution!(args)
    push!(solution_list, stage_solution)

    time_reorder_points = inventory_parameters.t_delivery
    for (k, t_k) in enumerate(time_reorder_points[2:end-1])
        println("reorder time-point: ($k, $t_k)")
        process_inventory_reorder_point!(args)
        vaccine_coverage = get_vaccine_stock_coverage(args)
        vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
        args["state"].action = vaccination_rate
        args["initial_condition"].action = vaccination_rate
        stage_solution = optimize_stage_solution!(args)
        push!(solution_list, stage_solution)
    end
    solution_path = vcat(solution_list...)
    return solution_path
end