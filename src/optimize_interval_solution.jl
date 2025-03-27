"""
    optimize_interval_solution(time_interval, x_0, a_t, k_0, parameters)

Optimize the solution for a given time interval by iterating over a set of operational stock levels 
and selecting the policy that minimizes the cost.

# Arguments
- `time_interval::Any`: The time interval over which the optimization is performed.
- `x_0::Any`: The initial state of the system.
- `a_t::Any`: The time-dependent parameter or control variable.
- `k_0::Any`: The initial stock level or related parameter.
- `parameters::Any`: A struct or dictionary containing additional parameters, including 
  `operational_stock_levels`, which is a collection of operational fractions to iterate over.

# Returns
- `opt_solution_t::Any`: The optimized solution for the given time interval, represented as a 
  data structure (e.g., matrix or array) where the last column contains the cost values.

# Details
The function evaluates the cost of the solution for each operational fraction (`rho_k`) in 
`parameters.operational_stock_levels`. It selects the solution with the minimum cost and 
returns it as the optimal solution.

# Notes
- The function assumes that `get_interval_solution!` is a pre-defined function that computes 
  the solution for a given policy and other inputs.
- The cost is extracted from the last column (index 11) of the solution matrix `solution_t`.
"""
function optimize_interval_solution(
  time_interval,
  x_0,
  a_t,
  k_0,
  parameters
)
  opt_cost = Inf
  operational_fractions = parameters.operational_stock_levels
  opt_solution = zeros(size(time_interval, 1), size(x_0, 2))
  for rho_k in operational_fractions
    policy = rho_k
    solution_t = get_interval_solution!(
      time_interval,
      x_0,
      policy,
      a_t,
      k_0,
      parameters
    )

    cost = solution_t[end, 11]
    if cost <= opt_cost
      opt_cost = cost
      opt_solution = solution_t
    end
  end

  return opt_solution
end