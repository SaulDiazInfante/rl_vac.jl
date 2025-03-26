"""
    get_simulation_statistics(
        data_path="./data/df_mc.csv",
        parameters_path = "par.json"
    )
    returns the median, and quintiles [0.25, 0.95] for each time of
    simulation.
    
# Arguments
- `data_path::String`: Path with the output of montecarlo sampling
- `parameters_path::String`: Path with the json source for config parameters
...
"""
function get_simulation_statistics(
    df_interpolated
)
    time_line = df_interpolated.time
    header_str = names(df_interpolated)
    df_lower_q_path = DataFrame()
    df_median_path = DataFrame()
    df_upper_q_path = DataFrame()

    n = size(time_line)[1]
    p = Progress(n, 1, "Computing time quantiles")
    for t in time_line
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
                        header_str,
                        median_state_t
                    )
                )
            )
        df_lower_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_str,
                        lower_q_state_t
                    )
                )
            )
        df_upper_q_path_ =
            DataFrame(
                Dict(
                    zip(
                        header_str,
                        upper_q_state_t
                    )
                )
            )
        df_median_path = [df_median_path; df_median_path_]
        df_lower_q_path = [df_lower_q_path; df_lower_q_path_]
        df_upper_q_path = [df_upper_q_path; df_upper_q_path_]
        next!(p; showvalues=[("time point ", j), ("from ", n)])
    end
    prefix_file_names = ["df_median", "df_lower_q", "df_upper_q"]
    suffix_file_name = ".csv"
    data = [df_median_path, df_lower_q_path, df_upper_q_path]


    for i = 1:3
        prefix = prefix_file_names[i]
        tag_args = Dict(
            "path" => "./data/",
            "prefix_file_name" => prefix,
            "suffix_file_name" => suffix_file_name
        )
        tag = tag_file(
            tag_args
        )
        CSV.write(tag, data[i])
    end
    return data
end
