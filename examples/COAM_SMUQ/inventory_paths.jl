using MakiePublication
using CairoMakie
using GLMakie
using rl_vac
using DataFrames
using CSV
using Debugger
CairoMakie.activate!()
const CRITICAL_TEMP = -70.0
n_paths = 2
alpha = 0.15

function interactive_plot(df_mc::DataFrame, file_name::AbstractString)
    COLORS = Dict(
        :inventory => [
            :dodgerblue,
            :tomato,
            :goldenrod,
            :mediumorchid
        ],
        :loss => :orangered,
        :temp => :seagreen,
        :temp_clipped => :darkorange,
        :threshold => :crimson
    )

    golden_ratio = (1.0 + sqrt(5.0)) / 2.0
    width_mm = 190.0
    height_mm = width_mm / golden_ratio
    dpi = 72.0

    width_px = round(Int, width_mm * dpi / 25.4)
    height_px = round(Int, height_mm * dpi / 25.4)


    figure = Figure(
        size=(width_px, height_px),
        fontsize=14
    )
    axtop = Axis(figure[1, 1], ylabel="Stock")
    axmidle = Axis(figure[2, 1], ylabel="Vaccine Loss")
    axbottom = Axis(figure[3, 1], xlabel="time (day)", ylabel="Optimal Policy")
    ax_right = Axis(figure[:, 2], xlabel="time (day)", ylabel=L"I_S")
    axs = [axtop, axmidle, axbottom, ax_right]
    labels = ["(A)", "(B)", "(C)", "(D)"]
    font_size = 18
    hv_offset = (4, -1)

    for (ax, label) in zip(axs, labels)
        text!(
            ax,
            0, 1,
            text=label,
            font=:bold,
            align=(:left, :top),
            offset=hv_offset,
            space=:relative,
            fontsize=font_size
        )
    end

    for i in 0:n_paths
        data_path_i = filter(
            :idx_path => n -> n == i,
            df_mc
        )
        lines!(
            axtop,
            data_path_i[!, :time],
            POP_SIZE * data_path_i[!, :K_stock_t],
            color=COLORS[:inventory][i+1]
        )
        band!(
            axtop,
            data_path_i[!, :time],
            0.0,
            POP_SIZE * data_path_i[!, :K_stock_t],
            color=(COLORS[:inventory][i+1],
                alpha)
        )
        lines!(
            axmidle,
            data_path_i[!, :time],
            #POP_SIZE * data_path_i[!, :opt_policy] .* data_path_i[!, :action]
            POP_SIZE * data_path_i[!, :stock_loss],
            color=COLORS[:inventory][i+1]
        )
        band!(
            axmidle,
            data_path_i[!, :time],
            0.0,
            #POP_SIZE * data_path_i[!, :opt_policy] .* data_path_i[!, :action],
            POP_SIZE * data_path_i[!, :stock_loss],
            color=(COLORS[:inventory][i+1],
                alpha
            )
        )
        lines!(
            axbottom,
            data_path_i[!, :time],
            data_path_i[!, :opt_policy],
            color=COLORS[:inventory][i+1]
        )
        band!(
            axbottom,
            data_path_i[!, :time],
            0.0,
            data_path_i[!, :opt_policy],
            color=(COLORS[:inventory][i+1], alpha)
        )
        lines!(
            ax_right,
            data_path_i[!, :time],
            POP_SIZE * data_path_i[!, :I_S],
            color=COLORS[:inventory][i+1]
        )
        band!(
            ax_right,
            data_path_i[!, :time],
            0.0,
            POP_SIZE * data_path_i[!, :I_S],
            color=(COLORS[:inventory][i+1], alpha)
        )
        filename = file_name * "_0" * string(i) * ".png"
        save(filename, figure, px_per_unit=10)
    end
    filename = file_name * ".png"
    save(filename, figure, px_per_unit=10)
    return figure
end

file_name = "df_mc.csv"
data_path = joinpath(
    dirname(@__DIR__),
    "../data/", file_name
)
df_mc = CSV.read(data_path, DataFrame)


fig_path = joinpath(
    dirname(@__DIR__),
    "../visualization/",
    "inventory_panel.png"
)

with_theme(theme_aps()) do
    interactive_plot(df_mc, fig_path)
end


