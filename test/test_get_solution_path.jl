using Test
using rl_vac
using DataFrames, CSV
using Debugger

function test_get_solution_path()

      args = build_testing_parameters()

      initial_condition = copy(args["initial_condition"])
      state = copy(args["state"])
      model_parameters = copy(args["model_parameters"])
      numeric_solver_parameters = copy(args["numeric_solver_parameters"])
      inventory_parameters = copy(args["inventory_parameters"])

      N_grid_size = numeric_solver_parameters.N_grid_size
      pop_size = model_parameters.N
      list_solution = Matrix{Real}[]
      df_solution = DataFrame()
      initial_condition_at_stage_k = copy(initial_condition)

      prior_inventory = 0.0
      for t in range(1, length(inventory_parameters.t_delivery) - 1)
            normalized_delivery_size_at_stake_k = (
                  inventory_parameters.delivery_size_k[t] / pop_size
            )
            current_inventory_size = prior_inventory +
                                     normalized_delivery_size_at_stake_k
            next_delivery_time = inventory_parameters.t_delivery[t+1]
            current_delivery_time = inventory_parameters.t_delivery[t]
            vaccine_coverage = get_vaccine_stock_coverage(args)
            vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
            stage_solution = optimize_stage_solution!(args)
            push!(list_solution, stage_solution)
            args["initial_condition"] = copy(args["state"])
      end
end

Debugger.@enter test_get_solution_path()