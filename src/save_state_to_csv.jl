"""
    save_state_to_csv(args::Dict{Symbol,Any}, filename::String) -> DataFrame

Saves the state information from a given dictionary `args` to a CSV file.

# Arguments
- `args::Dict{Symbol,Any}`: A dictionary containing the state information. 
  The state is expected to be accessible via the key `"state"`.
- `filename::String`: The name of the CSV file where the state information will be saved.

# Returns
- `DataFrame`: A DataFrame representation of the state information that was saved to the CSV file.

# Notes
- The function assumes that the state object has a type `structState` with defined fields.
- The fields of the `structState` type are extracted and their corresponding values are written to the CSV file.
- The `CSV` and `DataFrames` packages are used for writing the file and creating the DataFrame, respectively.

# Example
"""

function save_state_to_csv(state::structState, filename::String)
    dict_state = Dict(
        field => getfield(state, field) for field in fieldnames(structState)
    )
    df = DataFrame(dict_state)
    CSV.write(filename, df)
    return df
end



