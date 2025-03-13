using Debugger
using rl_vac
using DataFrames, CSV, JSON
using CairoMakie
CairoMakie.activate!()

sampling_size = 100
df_par, df_mc, path_par, path_mc = montecarlo_sampling(
    # Debugger.@enter montecarlo_sampling(
    sampling_size,
    "data/parameters_model.json"
)
df_stat = get_simulation_statistics()





