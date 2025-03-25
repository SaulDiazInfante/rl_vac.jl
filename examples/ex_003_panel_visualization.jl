using rl_vac
using DataFrames, CSV
using CairoMakie
CairoMakie.activate!()

path = joinpath("data", "df_mc.csv")
par_path = joinpath("data", "df_par(2025-03-15_12:13).csv")
df_mc = DataFrame(CSV.File(path))
df_par = DataFrame(CSV.File(par_path))
file_name = "experiment_02_fig_01.png"
pop_size = df_par[1, :N]
dark_latexfonts = merge(theme_dark(), theme_latexfonts())
ggplot_theme = Theme(
    Axis=(
        backgroundcolor=:gray90,
        leftspinevisible=false,
        rightspinevisible=false,
        bottomspinevisible=false,
        topspinevisible=false,
        xgridcolor=:white,
        ygridcolor=:white,
    )
)

with_theme(theme_latexfonts()) do
    # with_theme(dark_latexfonts) do
    get_panel_plot(df_mc, pop_size, 5, file_name)
end