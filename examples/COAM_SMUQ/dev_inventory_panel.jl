using MakiePublication
using CairoMakie
using GLMakie
using rl_vac
using LaTeXStrings
using DataFrames
using CSV
CairoMakie.activate!()
const CRITICAL_TEMP = -70.0

#args = build_testing_parameters()
#raw_sol = get_solution_path!(args)
#save_solution_path(raw_sol)


function interactive_plot(df::DataFrame, file_name::AbstractString)
    COLORS = Dict(
        :inventory => :dodgerblue,
        :loss => :orangered,
        :temp => :seagreen,
        :temp_clipped => :darkorange,
        :threshold => :crimson
    )

    golden_ratio = (1.0 + sqrt(5.0)) / 2.0
    width_mm = 190.0
    height_mm = width_mm * golden_ratio
    dpi = 72.0

    width_px = round(Int, width_mm * dpi / 25.4)
    height_px = round(Int, height_mm * dpi / 25.4)


    fig = Figure(
        size=(width_px, height_px),
        fontsize=14
    )

    ax1 = Axis(
        fig[1, 1],
        title="Inventory Size (vaccine jabs)",
        ylabel=L"K^{t_{n}^{(k)}} "
    )
    ax2 = Axis(
        fig[2, 1],
        title="Max vaccination rate (vaccine jabs per day)",
        ylabel=L"$\Psi_v$"
    )
    ax3 = Axis(
        fig[3, 1],
        title="Inventory Loss (vaccine jabs)",
        ylabel=L" L^{t_{n}^{(k)}}"
    )
    ax4 = Axis(
        fig[4, 1],
        title="Temperature (celsius)",
        ylabel=L"T(t)",
        xlabel=L"t\ (\text{days})"
    )
    axs = [ax1, ax2, ax3, ax4]
    labels = ["(A)", "(B)", "(C)", "(D)"]
    font_size = 16
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
    t = df.time
    y1 = POP_SIZE * df[:, :K_stock_t]
    y2 = POP_SIZE * df[:, :action]
    y3 = POP_SIZE * df[:, :stock_loss]
    y4 = df[:, :T]

    y4_active_loss = max.(CRITICAL_TEMP, y4)
    points = Point2f.(t, y4_active_loss)
    #
    linkxaxes!(ax1, ax2, ax3, ax4)
    lines!(
        ax1,
        t,
        y1;
        linestyle=:dot,
        color=:black
    )

    scatter!(ax1,
        t, y1,
        markersize=2,
        color=COLORS[:inventory]
    )
    lines!(ax2, t, y2, color=COLORS[:inventory])
    lines!(ax3, t, y3, color=COLORS[:loss])
    lines!(ax4, t, y4, color=COLORS[:temp])
    lines!(ax4,
        t, y4_active_loss,
        color=COLORS[:temp_clipped],
        linestyle=:solid
    )
    hlines!(ax4, -70.0, color=COLORS[:threshold], linestyle=:dash)
    poly!(
        ax4,
        points,
        color=(COLORS[:temp_clipped], 0.2),
        strokewidth=0
    )

    text!(
        ax4,
        -15.0, CRITICAL_TEMP - 4,
        text="Threshold: -70°C",
        align=(:left, :bottom),
        #space=:relative,
        color=COLORS[:threshold],
        fontsize=12
    )

    save(file_name, fig, px_per_unit=10)
    return fig
end

file_name = "solution_path(2025-05-04_13:31).csv"
data_path = joinpath(
    dirname(@__DIR__),
    "../data/", file_name
)
df = CSV.read(data_path, DataFrame)


fig_path = joinpath(
    dirname(@__DIR__),
    "../visualization/",
    "inventory_panel.png"
)

with_theme(theme_joss()) do
    interactive_plot(df, fig_path)
end


