using CSV
using CairoMakie
using DataFrames
using rl_vac
using Dates
CairoMakie.activate!()

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
    f = get_epidemic_states_confidence_bands(
        df_lower_q,
        df_median,
        df_upper_q,
        df_mc,
        pop_size,
        "./visualization/confidence_bands.png"
    )
end