using Test  # Ensure the Test module is imported for @test macro
using rl_vac
using DataFrames, CSV

args = build_testing_parameters()

initial_condition = args["initial_condition"]
state = args["state"]
model_parameters = args["model_parameters"]
numeric_solver_parameters = args["numeric_solver_parameters"]
inventory_parameters = args["inventory_parameters"]


N_grid_size = numeric_solver_parameters.N_grid_size
pop_size = model_parameters.N
list_solution = []
df_solution = DataFrame()
prior_inventory = 0.0
initial_condition_at_stage_k = get_struct_values(initial_condition)

for t in range(1, length(inventory_parameters.t_delivery) - 1)
      normalized_delivery_size_at_stake_k = (
            inventory_parameters.delivery_size_k[t] / pop_size
      )
      current_inventory_size = prior_inventory +
                               normalized_delivery_size_at_stake_k
      next_delivery_time = inventory_parameters.t_delivery[t+1]
      current_delivery_time = inventory_parameters.t_delivery[t]
      h = (
            next_delivery_time -
            current_delivery_time
      ) / N_grid_size
      time_interval_k = LinRange(
            current_delivery_time + h,
            next_delivery_time,
            N_grid_size
      )

      vaccine_coverage = get_vaccine_stock_coverage(args)
      vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)


end