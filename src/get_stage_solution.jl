
"""
    get_interval_solution!(args::Dict{String,Any})::Matrix{Float64}

Compute the solution of a system over a specified interval using a numerical solver.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"initial_condition"`: An object representing the initial state of the system.
  - `"numeric_solver_parameters"`: A struct or dictionary containing numerical solver parameters, including:
    - `N_grid_size`: The number of grid points for the solution.

# Returns
- `Matrix{Float64}`: A matrix where each row corresponds to the state of the system at a grid point.

# Details
- The function initializes the solution matrix `sol` with zeros.
- The initial condition is extracted and set as the first row of the solution matrix.
- The function iteratively computes the state of the system at each grid point using the `rhs_evaluation!` function and updates the solution matrix.

# Notes
- The `rhs_evaluation!` function is expected to compute the right-hand side of the system and update the state.
- The `structState` type is assumed to define the structure of the system's state, and its field names are used to extract initial state values.
"""
function get_stage_solution!(args::Dict{String,Any})::Matrix{Real}

    state_dim = length(fieldnames(structState))
    numeric_solver_par = args["numeric_solver_parameters"]
    N_grid_size = numeric_solver_par.N_grid_size
    initial_condition = args["initial_condition"]
    time_interval_stencil = build_interval_stencil!(args)
    initial_condition.time = time_interval_stencil[1]

    x_new = zeros(Real, state_dim)
    sol = zeros(Real, N_grid_size, state_dim)
    initial_state_values = get_struct_values(args["initial_condition"])
    x_00 = initial_state_values
    x_new = initial_state_values
    sol[1, :] = x_00

    for (j, t_j) in enumerate(time_interval_stencil[2:end])
        args["state"].time = t_j
        x_new = rhs_evaluation!(args)
        sol[j+1, :] = x_new
    end
    return sol
end
