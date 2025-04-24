"""
    save_solution_path(sol::Matrix{Real})::DataFrame

Saves a solution path represented as a matrix to a CSV file and returns it as a DataFrame.

# Arguments
- `sol::Matrix{Real}`: A matrix where each row represents a state in the solution path, 
  and each column corresponds to a field in the `structState`.

# Returns
- `DataFrame`: A DataFrame representation of the solution path.

# Details
- The column names for the DataFrame are derived from the field names of the `structState` type.
- The file is saved in the directory specified by the `"path"` key in the `dict_tag` dictionary.
- The file name is constructed using the `"prefix_file_name"` and `"suffix_file_name"` keys in the `dict_tag` dictionary.
- The file is saved in CSV format using the `CSV.write` function.

# Notes
- Ensure that the `structState` type is defined and accessible in the scope where this function is called.
- The `tag_file` function is used to generate the full file name. Ensure it is implemented and available.
"""
function save_solution_path(sol::Matrix{Real})::DataFrame
    col_names = fieldnames(structState)
    df_solution = DataFrame(sol, collect(col_names))
    file_path = joinpath(
        @__DIR__,
        "../data/"
    )
    dict_tag = Dict(
        "path" => file_path,
        "prefix_file_name" => "solution_path",
        "suffix_file_name" => ".csv"
    )
    file_name = tag_file(dict_tag)
    CSV.write(file_name, df_solution)
    return df_solution
end
