using Test
using rl_vac
using DataFrames, CSV
using Debugger
using Plots

function test_get_solution_path()
      args = build_testing_parameters()
      process_first_inventory_reorder_point!(args)
      initial_condition = copy(args["initial_condition"])
      state = copy(args["state"])
      model_parameters = copy(args["model_parameters"])
      numeric_solver_parameters = copy(args["numeric_solver_parameters"])
      inventory_parameters = copy(args["inventory_parameters"])

      list_solution = Matrix{Real}[]
      df_solution = DataFrame()

      vaccine_coverage = get_vaccine_stock_coverage(args)
      vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
      args["state"].action = vaccination_rate
      args["initial_condition"].action = vaccination_rate
      stage_solution = optimize_stage_solution!(args)
      push!(list_solution, stage_solution)
      x = stage_solution[:, 1]
      y1 = stage_solution[:, 13]
      y2 = POP_SIZE * stage_solution[:, 15]
      y3 = stage_solution[:, 14]
      Plots.plot(
            x, y1,
            layout=(3, 1),         # 3 rows, 1 column
            link=:t,               # share the x-axis
            label="Inventory",           # legend label for first subplot
            title="Stock"
      )


      plot()
      time_reorder_points = inventory_parameters.t_delivery

      for t in time_reorder_points[2:end-1]
            println("reorder time-point: $(t)")
            process_inventory_reorder_point!(args)
            vaccine_coverage = get_vaccine_stock_coverage(args)
            vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
            args["state"].action = vaccination_rate
            args["initial_condition"].action = vaccination_rate
            stage_solution = optimize_stage_solution!(args)
            push!(list_solution, stage_solution)
            plot!(stage_solution[:, 1], POP_SIZE * stage_solution[:, 13])
      end
      plot(stage_solution[:, 1],)
      plot(stage_solution[:, 1],)
end
Debugger.@enter test_get_solution_path()