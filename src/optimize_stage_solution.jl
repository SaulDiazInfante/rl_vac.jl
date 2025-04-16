"""
  optimize_stage_solution!(args::Dict{String,Any})

Optimizes the stage solution for a given set of parameters and initial conditions.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"initial_condition"`: The initial condition object, which includes the starting state and policy.
  - `"numeric_solver_parameters"`: A dictionary containing numerical solver parameters, including `N_grid_size`.
  - `"inventory_parameters"`: A dictionary containing inventory-related parameters, including `operational_stock_levels`.

# Details
The function iterates over a set of operational stock levels (`operational_fractions`) and computes the stage solution for each level using the `get_stage_solution!` function. It evaluates the cost associated with each solution and keeps track of the optimal solution with the lowest cost.

# Returns
- `opt_solution`: A 2D array representing the optimal solution for the stage, with dimensions `(N_grid_size, state_dim)`.

# Notes
- The function modifies the `args` dictionary in-place.
- The `state_dim` is determined by the number of fields in the `structState` type.
- The function assumes the presence of a `"state"` key in `args` with a field `X_0_mayer` representing the cost.

# Example
"""
function optimize_stage_solution!(
  args::Dict{String,Any}
)

  initial_condition = copy(args["initial_condition"])
  numeric_solver_par = copy(args["numeric_solver_parameters"])
  inventory_parameters = copy(args["inventory_parameters"])

  N_grid_size = numeric_solver_par.N_grid_size
  operational_fractions = inventory_parameters.operational_stock_levels
  state_dim = length(fieldnames(structState))

  solution_t = zeros(Real, N_grid_size, state_dim)
  opt_solution = zeros(Real, N_grid_size, state_dim)
  opt_cost = Inf
  copy_args = copy(args)
  for rho_k in operational_fractions
    initial_condition.opt_policy = rho_k
    copy_args["initial_condition"] = copy(initial_condition)
    copy_args["state"] = copy(initial_condition)
    solution_t = get_stage_solution!(copy_args)
    cost = copy_args["state"].X_0_mayer
    if cost <= opt_cost
      opt_cost = cost
      opt_solution = solution_t
      args = copy(copy_args)
    end
  end
  return opt_solution
end

