"""
    get_simulation_statistics(
        data_path="./data/df_mc.csv",
        parameters_path = "par.json"
    )
    returns the median, and qunatiles [0.25, 0.95] for each time of
    simulation.
    
# Arguments
- `data_paht::String`: Path with the output of montecarlo sampling
- `parameters_path::String`: Path with the json source for config parameters
...
"""
function get_simulation_statistics(
    data_path = "./data/df_mc.csv",
    parameters_path = "./data/parameters_model.json"
)
    trajectories = CSV.read(data_path, DataFrame);
    dropmissing!(trajectories)
    # obtain dimmensions
    parameters = load_parameters()
    idx_0 = (trajectories.idx_path .== 1);
    query = trajectories[idx_0, :];
    line_time = query.time
#
#
#
    interpolated_trajectory_1 =
        get_interpolated_solution(query, line_time);
    idx_path = unique(trajectories, :idx_path).idx_path
    df_interpolated = DataFrame()
    df_interpolated = [df_interpolated; interpolated_trajectory_1]
    n = size(idx_path[2:end])[1]
    p = Progress(n, 1, "Interpolating");
    for j in idx_path[2:end]
        idx_j = (trajectories.idx_path .== j)
        trajectory_j = trajectories[idx_j, :]
        #print("\n path: ", j)
        interpolated_trajectory_j =
            get_interpolated_solution(trajectory_j, line_time)
        df_interpolated = [df_interpolated; interpolated_trajectory_j]
        next!(p)
    end
    # saving interpolated time seires
    prefix_file_name = "df_interpolated"
    d = Dates.now()
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    sufix_file_name = ".csv"
    csv_file_name = prefix_file_name * tag * sufix_file_name
    path_par = "./data/" * csv_file_name
    CSV.write(path_par, df_interpolated)
    # Gettin statistics over the firs observation
    t_zero = line_time[1]
    idx_t = (df_interpolated.time .== t_zero)
#
    query_on_time_zero = df_interpolated[idx_t, :]
    median_state_t = [median(c) for c in eachcol(query_on_time_zero)]
    lower_q_state_t = [quantile(c, 0.05) for c in eachcol(query_on_time_zero)]
    upper_q_state_t = [quantile(c, 0.95) for c in eachcol(query_on_time_zero)]
    header_strs = names(query_on_time_zero)
    df_median_path = DataFrame()
    df_lower_q_path = DataFrame()
    df_upper_q_path = DataFrame()
    df_median_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    median_state_t
                )
            )
        )
    df_lower_q_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    lower_q_state_t
                )
            )
        )
    df_upper_q_path_ =
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    upper_q_state_t
                )
            )
        )
    df_median_path = [df_median_path; df_median_path_]
    df_lower_q_path = [df_lower_q_path; df_lower_q_path_]
    df_upper_q_path = [df_upper_q_path; df_upper_q_path_]
    time_ = line_time
    for t in time_[2:end]
        idx_t = (df_interpolated.time .== t)
        query_on_time = df_interpolated[idx_t, :]
        median_state_t = [median(c) for c in eachcol(query_on_time)]
        lower_q_state_t = [quantile(c, 0.05) for c in eachcol(query_on_time)]
        upper_q_state_t = [quantile(c, 0.95) for c in eachcol(query_on_time)]
    #       
        df_median_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        median_state_t
                    )
                )
            )
        df_lower_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        lower_q_state_t
                    )
                )
            )
        df_upper_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_strs,
                        upper_q_state_t
                    )
                )
            )
        df_median_path = [df_median_path; df_median_path_]
        df_lower_q_path = [df_lower_q_path; df_lower_q_path_]
        df_upper_q_path = [df_upper_q_path; df_upper_q_path_]
    end
    prefix_file_names = ["df_median", "df_lower_q", "df_upper_q"]
    data = [df_median_path, df_lower_q_path, df_upper_q_path]
    d = Dates.now()
    sufix = ".csv"
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    for i = 1:3
        prefix = prefix_file_names[i]
        csv_file_name_ = "./data/" * prefix * sufix_file_name
        csv_file_name = "./data/" * prefix * tag * sufix_file_name
        CSV.write(csv_file_name_, data[i])
        CSV.write(csv_file_name, data[i])
    end
    N = parameters.N[1]
    trace1 =
        PlotlyJS.scatter(
            x=df_median_path.time,
            y=N * df_median_path.I_S,
            mode="lines",
            name="I_S")
    trace2 =
        PlotlyJS.scatter(
            x=df_lower_q_path.time,
            y=N * df_lower_q_path.I_S,
            mode="lines",
            name="lower_I_S"
        )
    trace3 =
        PlotlyJS.scatter(
            x=df_upper_q_path.time,
            y=N * df_upper_q_path.I_S,
            mode="lines",
            name="upper_I_S"
        )
    fig = PlotlyJS.plot([trace1, trace2, trace3])
    open("./plot_fig3.html", "w") do io
        PlotlyBase.to_html(io, fig.plot)
    end
    # TODO implement return
    return data
end
