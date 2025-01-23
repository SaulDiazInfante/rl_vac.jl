"""
    get_deterministic_plot_path(
        df_mc::DataFrame,
        pop_size::Float64,
        file_name_f1::AbstractString,
        file_name_f2::AbstractString
    )
        
Returns two figures that encloses a the visualization of
the reference deterministic path with the evolution of the
dynamic model and the regarding policy. 
---

### Input

- `df_mc::DataFrame`: DataFrame with the opt_Policy col from MonteCarlo Sampling 
- `pop_size::Float64`:
- `file_name_f1::AbstractString`:
- `file_name_f2::AbstractString`:

### Output
Makie object and a file graph with extension .png

"""

function get_deterministic_plot_path(
    df_mc::DataFrame,
    pop_size::Float64,
    file_name_f1::AbstractString,
    file_name_f2::AbstractString
)
    #
    mm_to_inc_factor = 1 / 25.4
    golden_ratio = 1.618
    size_mm = 180
    size_inches = mm_to_inc_factor .* (size_mm, size_mm / golden_ratio)
    size_pt_f1 = 72.0 .* size_inches
    font_size = 18
    hv_offset = (4, -1)

    f1 = Figure(
        resolution=size_pt_f1,
        fontsize=12
    )
    # colors
    f2 = Figure(
        resolution=size_pt_f1,
        fontsize=12
    )
    color_ref = (:grey0, 1.0)
    ax_top_1_f1 = Axis(
        f1[1, 1],
        ylabel=L"$K_t$ (No. doses)"
    )
    ax_bottom_1_f1 = Axis(
        f1[2, 1],
        ylabel=L"$\psi_V^{(k)}$ (doses/day)",
        xlabel="time (day)"
    )

    ax_top_1_f2 = Axis(
        f2[1, 1],
        ylabel=L"S"
    )
    ax_top_2_f2 = Axis(
        f2[1, 2],
        ylabel=L"E"
    )
    ax_top_3_f2 = Axis(
        f2[1, 3],
        ylabel=L"I_S"
    )

    ax_bottom_1_f2 = Axis(
        f2[2, 1],
        ylabel=L"I_A",
        xlabel="time (day)"
    )
    ax_bottom_2_f2 = Axis(
        f2[2, 2],
        ylabel=L"V",
        xlabel="time (day)"
    )
    ax_bottom_3_f2 = Axis(
        f2[2, 3],
        ylabel=L"Coverage $X_{VAC}$",
        xlabel="time (day)"
    )

    axs = [
        ax_top_1_f1,
        ax_bottom_1_f1,
        ax_top_1_f2,
        ax_top_2_f2,
        ax_top_3_f2,
        ax_bottom_1_f2,
        ax_bottom_2_f2,
        ax_bottom_3_f2
    ]
    labels = ["(A)", "(B)", "(A)", "(B)", "(C)", "(D)", "(E)", "(F)"]
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

    #
    df_ref = filter(
        :idx_path => n -> n == 1,
        df_mc
    )
    hidexdecorations!(ax_top_1_f1, grid=false)
    hidexdecorations!(ax_top_1_f2, grid=false)
    hidexdecorations!(ax_top_2_f2, grid=false)
    hidexdecorations!(ax_top_3_f2, grid=false)

    # Stock-Vaccination Rate

    lines!(
        ax_top_1_f1,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )

    lines!(
        ax_bottom_1_f1,
        df_ref[!, :time],
        pop_size * df_ref[!, :action],
        color=color_ref
    )

    # Epidemic states

    lines!(
        ax_top_1_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :S],
        color=color_ref
    )

    lines!(
        ax_top_2_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :E],
        color=color_ref
    )

    lines!(
        ax_top_3_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_S],
        color=color_ref
    )

    lines!(
        ax_bottom_1_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_A],
        color=color_ref
    )

    lines!(
        ax_bottom_2_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :D],
        color=color_ref
    )

    lines!(
        ax_bottom_3_f2,
        df_ref[!, :time],
        pop_size * df_ref[!, :X_vac],
        color=color_ref
    )

    #= l = Legend(
        f[5, 1, Top()],
        [med_line, band_],
        ["median", "95% Conf."]
    )

    l.orientation = :horizontal
    =#
    filename_f1 = file_name_f1
    filename_f2 = file_name_f2
    save(filename_f1, f1)
    save(filename_f2, f2, px_per_unit=10)
    return f1, f2
end
