using Test  # Ensure the Test module is imported for @test macro
using rl_vac
using DataFrames, CSV

par = load_parameters_to_df("./data/parameters_model.json")
x_0, df_solution = get_solution_path!(par)
@test typeof(x_0) == DataFrame  # Check if x_0 is a DataFrame
@test typeof(df_solution) == DataFrame  # Check if df_solution is a DataFrame
@test size(x_0)[2] == 17  # Check if x_0 has 17 columns
@test size(df_solution)[1] ==
      par.N_grid_size[1] * (size(par.t_delivery)[1] - 1)
