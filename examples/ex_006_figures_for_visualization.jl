using CSV
using MakiePublication
using CairoMakie
using DataFrames
using Test
using rl_vac
CairoMakie.activate!(type="svg")

path_lower_q = joinpath("data", "df_lower_q.csv")
path_median = joinpath("data", "df_median.csv")
path_upper_q = joinpath("data", "df_upper_q.csv")

path_mc_sampling = joinpath("data", "df_mc.csv")
path_par = joinpath("data", "df_par(2025-03-14_13:11).csv")

df_lower_q = DataFrame(CSV.File(path_lower_q))
df_median = DataFrame(CSV.File(path_median))
df_upper_q = DataFrame(CSV.File(path_upper_q))
df_mc = DataFrame(CSV.File(path_mc_sampling))
df_par = DataFrame(CSV.File(path_par))

pop_size = df_par[1, :N]
dark_latexfonts = merge(theme_dark(), theme_latexfonts())

# with_theme(dark_latexfonts) do
vis_path = "./visualization/"
file_name_01 = joinpath(vis_path, "experiment_01_fig_01.png")
file_name_02 = joinpath(vis_path, "experiment_01_fig_02.png")
file_name_03 = joinpath(vis_path, "experiment_02_fig_01")
file_name_04 = joinpath(vis_path, "experiment_03_fig_01")
file_name_05 = joinpath(vis_path, "experiment_03_fig_02.png")

with_theme(theme_aps()) do
    f_01, f_02 = get_deterministic_plot_path(
        df_mc,
        pop_size,
        file_name_01,
        file_name_02
    )

    f_03 = get_panel_plot(
        df_mc,
        pop_size,
        5,
        file_name_03
    )

    f_04 = get_confidence_bands(
        df_lower_q,
        df_median,
        df_upper_q,
        df_mc,
        pop_size,
        file_name_04
    )
    f_05 = get_epidemic_states_confidence_bands(
        df_lower_q,
        df_median,
        df_upper_q,
        df_mc,
        pop_size,
        file_name_05
    )
end