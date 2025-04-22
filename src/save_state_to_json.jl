

"""
    save_state_to_json(state::structState, filename::String) -> DataFrame

Saves the fields of a `structState` instance to a JSON file and returns a DataFrame representation of the state.

# Arguments
- `state::structState`: An instance of the `structState` type whose fields will be saved.
- `filename::String`: The base name of the JSON file (without the `.json` extension) where the state will be saved.

# Returns
- A `DataFrame` containing the fields of the `structState` instance.

# Details
- The function converts the fields of the `structState` instance into a dictionary (`Dict`).
- The dictionary is then written to a JSON file with the specified filename and a `.json` extension using `JSON3.write`.
- A `DataFrame` is created from the dictionary and returned.

# Example
"""

StructTypes.StructType(::Type{structState}) = StructTypes.Struct()
function save_state_to_json(state::structState, filename::String)
    dict_state = Dict(
        field => getfield(state, field) for field in fieldnames(structState)
    )
    df = DataFrame(dict_state)

    JSON3.write(filename, dict_state)
    return df
end



