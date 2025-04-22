using Test
using rl_vac
using DataFrames, CSV
using Debugger

function test_get_solution_path()
      args = build_testing_parameters()
      process_first_inventory_reorder_point!(args)
      initial_condition = copy(args["initial_condition"])
      state = copy(args["state"])
      model_parameters = copy(args["model_parameters"])
      numeric_solver_parameters = copy(args["numeric_solver_parameters"])
      inventory_parameters = copy(args["inventory_parameters"])

      N_grid_size = numeric_solver_parameters.N_grid_size
      pop_size = model_parameters.N
      list_solution = Matrix{Real}[]
      df_solution = DataFrame()

      vaccine_coverage = get_vaccine_stock_coverage(args)
      vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
      args["state"].action = vaccination_rate
      args["initial_condition"].action = vaccination_rate
      stage_solution = optimize_stage_solution!(args)
      push!(list_solution, stage_solution)

      for t in range(1, length(inventory_parameters.t_delivery) - 2)
            process_inventory_reorder_point!(args)
            vaccine_coverage = get_vaccine_stock_coverage(args)
            vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
            args["state"].action = vaccination_rate
            args["initial_condition"].action = vaccination_rate
            stage_solution = optimize_stage_solution!(args)
            push!(list_solution, stage_solution)
      end
end
Debugger.@enter test_get_solution_path()