"""
    get_panel_plot(df_mc::DataFrame, pop_size::Float64, n_paths::Int, file_name::AbstractString
    )

Returns a figure that encloses a panel visualization with 
vaccine stock,
vaccination rate, and optimal decision at the left, 
and the Infect class evolution on the right for a number of 
n_paths realizations.

# Arguments
- `df_mc::DataFrame`: DataFrame with the MonteCarlo Sampling
- `pop_size::Float64`: Population size to scale Incidence and Number of doses
- `n_paths::Int`: Number of sampling paths to plot
...
"""

function get_panel_plot(
    df_mc::DataFrame,
    pop_size::Float64,
    n_paths::Int,
    file_name::AbstractString
)
    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 190
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f = 72.0 .* size_inches
    f = Figure(
        resolution=size_pt_f,
        fontsize=12
    )

    axtop = Axis(f[1, 1], ylabel="Stock")
    axmidle = Axis(f[2, 1], ylabel="Vaccination rate")
    axbottom = Axis(f[3, 1], xlabel="time (day)", ylabel="Decision")
    ax_right = Axis(f[:, 2], xlabel="time (day)", ylabel=L"I_S")
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

    for i in 1:n_paths
        data_path_i = filter(
            :idx_path => n -> n == i,
            df_mc
        )
        lines!(
            axtop,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :K_stock_t]
        )
        band!(
            axtop,
            data_path_i[!, :time],
            0.0,
            pop_size * data_path_i[!, :K_stock_t],
            alpha=0.3
        )
        lines!(
            axmidle,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :opt_policy] .* data_path_i[!, :action]
        )
        band!(
            axmidle,
            data_path_i[!, :time],
            0.0,
            pop_size * data_path_i[!, :opt_policy] .* data_path_i[!, :action],
            alpha=0.2
        )
        lines!(
            axbottom,
            data_path_i[!, :time],
            data_path_i[!, :opt_policy]
        )
        lines!(
            ax_right,
            data_path_i[!, :time],
            pop_size * data_path_i[!, :I_S]
        )
        filename = file_name * "_0" * string(i) * ".png"
        save(filename, f, px_per_unit=10)
    end
    filename = file_name * ".png"
    save(filename, f, px_per_unit=10)
    return f
end
