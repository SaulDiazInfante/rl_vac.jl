"""
    save_interval_solution(sol::Matrix{Real})::DataFrame

Saves the interval solution represented by the matrix `sol` into a CSV file and returns it as a DataFrame.

# Arguments
- `sol::Matrix{Real}`: A matrix containing the interval solution data. Each column corresponds to a field in the `structState` type.

# Returns
- `DataFrame`: A DataFrame representation of the interval solution.

# Details
- The column names for the DataFrame are derived from the field names of the `structState` type.
- The file name for the CSV is generated dynamically based on the value of the `:t_index_interval` column in the first row of the DataFrame. The file is saved in the current working directory with the name format `"interval_solution_0<idx>.csv"`, where `<idx>` is the value of `:t_index_interval`.

# Dependencies
- Requires the `DataFrames` and `CSV` packages to be available in the environment.

# Example
"""

function save_interval_solution(sol::Matrix{Real})::DataFrame
    col_names = fieldnames(structState)
    df_interval_solution = DataFrame(sol, collect(col_names))
    idx = df_interval_solution[1, :t_index_interval]
    file_name = "interval_solution_0$(idx).csv"
    CSV.write(file_name, df_interval_solution)
    return df_interval_solution
end
