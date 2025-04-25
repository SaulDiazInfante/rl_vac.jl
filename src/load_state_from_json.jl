
"""
    load_state_from_json(json_file_name)::DataFrame

Loads a JSON file and converts its contents into a `DataFrame`.

# Arguments
- `json_file_name::String`: The path to the JSON file to be loaded. Defaults to `"./data/parameters_model.json"`.

# Returns
- `DataFrame`: A DataFrame containing the data parsed from the JSON file.

# Example
"""
function load_state_from_json(
    json_file_name::String
)::DataFrame
    if !isfile(json_file_name)
        throw(SystemError("File not found: $json_file_name"))
    end
    try
        _ = JSON3.read(json_file_name)
        # Process the JSON data as needed
    catch e
        if isa(e, JSON3.Error)
            throw(ArgumentError("Invalid JSON format in file: $json_file_name"))
        else
            throw(JSON3.Error("Invalid JSON format"))
        end
    end
    parsed_data = JSON3.read(json_file_name)
    df_state = DataFrame(parsed_data)
    return df_state
end