using rl_vac
using DataFrames, CSV, JSON

sampling_size = 10000
df_par, df_mc, path_par, path_mc = montecarlo_sampling(
    sampling_size,
    "data/parameters_model.json"
)
# df_interpolated = interpolate_mc_paths()
df_interpolated = CSV.read("data/df_interpolated.csv", DataFrame)
df_stat = get_simulation_statistics(df_interpolated)


