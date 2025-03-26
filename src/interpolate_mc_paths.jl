
"""
    interpolate_mc_paths(data_path="./data/df_mc.csv")

Interpolates Monte Carlo simulation paths from a CSV file and writes the interpolated data to a new CSV file.

# Arguments
- `data_path::String`: The file path to the input CSV file containing the Monte Carlo simulation data. Defaults to `"./data/df_mc.csv"`.

# Returns
- `DataFrame`: A DataFrame containing the interpolated simulation paths.

# Description
This function reads Monte Carlo simulation data from the specified CSV file, removes missing values, and interpolates the simulation paths based on a reference time vector. The interpolation is performed for each unique path in the data. A progress bar is displayed during the interpolation process.

The interpolated data is saved to a new CSV file with a filename constructed using a predefined tag dictionary.

# Notes
- The input CSV file is expected to have columns `idx_path` (path identifier) and `time` (time points).
- The function uses `get_interpolated_solution` to perform the interpolation for each path.
- The output file is saved in the `./data/` directory with a prefix of `"df_interpolated"` and a suffix of `".csv"`.
"""
function interpolate_mc_paths(data_path="./data/df_mc.csv")

    buffer = CSV.read(data_path, DataFrame)
    dropmissing!(buffer)

    idx_0 = (buffer.idx_path .== 1)
    query = buffer[idx_0, :]
    time_line = query.time
    idx_path = unique(buffer, :idx_path).idx_path
    df_interpolated = DataFrame()
    n = size(idx_path)[1]

    p = Progress(n, 1, "Interpolating")
    for j in idx_path
        idx_j = (buffer.idx_path .== j)
        trajectory_j = buffer[idx_j, :]
        interpolated_trajectory_j =
            get_interpolated_solution(trajectory_j, time_line)
        df_interpolated = [df_interpolated; interpolated_trajectory_j]
        next!(p; showvalues=[("realization ", j), ("from ", n)])
    end
    tag_args = Dict(
        "path" => "./data/",
        "prefix_file_name" => "df_interpolated",
        "suffix_file_name" => ".csv"
    )
    tag = tag_file(tag_args)
    CSV.write(tag, df_interpolated)
    return df_interpolated
end