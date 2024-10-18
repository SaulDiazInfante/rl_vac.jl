"""
Returns a figure that encloses a panel visualization with 
the confidence bands from quartiles 0.5 and .95 for the variables:
vaccine stock, vaccination rate, and Symptomatic Infected.
Also plots a counts for the decision at the left, 
and the Infecte class evulution on the right for a number of 
n_paths realizations.

# Arguments
- `df_lower_q::DataFrame`: 
- `df_median::DataFrame`:
- `df_upper_q::DataFrame`:
- `df_ref::DataFrame`: DataFrame with the opt_Policy col from MonteCarlo Sampling 
- `pop_size::Float64`:
- `file_name::AbstractString`:
"""

function get_confidence_bands(
    df_lower_q::DataFrame,
    df_median::DataFrame,
    df_upper_q::DataFrame,
    df_mc::DataFrame,
    pop_size::Float64,
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

    # colors
    # color_q = (:azure, 1.0)
    color_m = (:orange, 0.4)
    color_ref = (:grey0, 1.0)
    axtop = Axis(
        f[1, 1],
        ylabel="Stock"
    )
    axmidle = Axis(
        f[2, 1],
        xlabel="time (day)",
        ylabel="Vaccination rate"
    )
    axbottom = Axis(
        f[3, 1],
        xlabel="Decision",
        ylabel="Count"
    )
    axright = Axis(
        f[1:3, 2],
        xlabel="time (day)",
        ylabel=L"I_S"
    )

    axs = [axtop, axmidle, axbottom, axright]
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

    #
    df_ref = filter(
        :idx_path => n -> n == 1,
        df_mc
    )

    # Stock
    ref_line = lines!(
        axtop,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )
    i = 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    lines!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :K_stock],
        color=color_ref
    )

    lines!(
        axtop,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :K_stock],
        color=color_ref
    )

    band_ = band!(
        axtop,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :K_stock],
        pop_size * df_upper_q[!, :K_stock],
        alpha=0.3
    )

    lines!(
        axtop,
        df_ref[!, :time],
        pop_size * df_ref[!, :K_stock],
        color=color_ref
    )
    med_line = lines!(
        axtop,
        df_median[!, :time],
        pop_size * df_median[!, :K_stock],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)
    lines!(
        axtop,
        df_median[!, :time],
        pop_size * df_median[!, :K_stock],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    # Vaccination rate
    lines!(
        axmidle,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :action],
        color=color_ref
    )

    lines!(
        axmidle,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :action],
        color=color_ref
    )

    band!(
        axmidle,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :action],
        pop_size * df_upper_q[!, :action],
        alpha=0.3
    )

    lines!(
        axmidle,
        df_ref[!, :time],
        pop_size * df_ref[!, :action],
        color=color_ref
    )

    lines!(
        axmidle,
        df_median[!, :time],
        pop_size * df_median[!, :action],
        color=color_m
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)


    # Symtomatic Infected class
    lines!(
        axright,
        df_upper_q[!, :time],
        pop_size * df_upper_q[!, :I_S],
        color=color_ref,
        label="Reference"
    )

    lines!(
        axright,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        color=color_ref
    )

    band!(
        axright,
        df_lower_q[!, :time],
        pop_size * df_lower_q[!, :I_S],
        pop_size * df_upper_q[!, :I_S],
        alpha=0.3,
        label="CI 95%"
    )

    lines!(
        axright,
        df_ref[!, :time],
        pop_size * df_ref[!, :I_S],
        color=color_ref
    )

    lines!(
        axright,
        df_median[!, :time],
        pop_size * df_median[!, :I_S],
        color=color_m,
        label="median"
    )
    i = i + 1
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f)

    # Counter plot
    descision = df_mc[!, :opt_policy]
    df_descision = DataFrame(opt_policy=descision)
    df_descision_01 = df_descision[
        (df_descision.opt_policy.==0.0).|(df_descision.opt_policy.==1.0),
        :]


    count_opt_decs = countmap(df_descision_01[!, :opt_policy])
    barplot!(
        axbottom,
        collect(keys(count_opt_decs)),
        collect(values(count_opt_decs)),
        strokecolor=:black,
        strokewidth=2,
        #colormap =colors[1:size(collect(keys(count_opt_decs)))[1]]
        # color=[:red, :orange, :azure, :brown]
        color=[:red, :azure]
    )
    #= l = Legend(
        f[4, 1:2, Top()],
        [ref_line, med_line, band_],
        ["reference path", "median", "95% Conf."]
    )

    l.orientation = :horizontal
    =#
    i = i + 1
    axislegend(
        axright,
        merge=true,
        unique=true,
        position=:rb,
        nbanks=2,
        rowgap=10,
        orientation=:horizontal
    )
    filename = file_name * "_0" * string(i) * ".png"
    save(filename, f, px_per_unit=10)
    filename = file_name * ".png"
    save(filename, f, px_per_unit=10)
    return f
end
