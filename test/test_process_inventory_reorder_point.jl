using Test
using rl_vac
using DataFrames, CSV
using Debugger


args = build_testing_parameters()
process_first_inventory_reorder_point!(args)

model_parameters = copy(args["model_parameters"])
numeric_solver_parameters = copy(args["numeric_solver_parameters"])
inventory_parameters = copy(args["inventory_parameters"])

stage_solution = optimize_stage_solution!(args)

initial_condition = copy(args["initial_condition"])
state = copy(args["state"])

N_grid_size = numeric_solver_parameters.N_grid_size
pop_size = model_parameters.N
initial_condition_at_stage_k = copy(initial_condition)

prior_inventory_size = state.K_stock_t
prior_delivery_time = initial_condition.time
current_state_time = state.time
stage_index = get_stencil_projection(current_state_time, inventory_parameters)

