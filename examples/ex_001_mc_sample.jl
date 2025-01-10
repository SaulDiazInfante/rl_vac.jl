using Debugger
using rl_vac
using DataFrames, CSV, JSON
using CairoMakie
CairoMakie.activate!()
#=


df_par, df_mc, path_par, path_mc = montecarlo_sampling(
    sampling_size,
    "data/parameters_model.json"
)
df_stat = get_simulation_statistics()
=#
function main()
    sampling_size = 1000
    df_par, df_mc, path_par, path_mc = montecarlo_sampling(
        sampling_size,
        "data/parameters_model.json"
    )
end

main()





