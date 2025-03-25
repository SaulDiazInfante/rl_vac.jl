"""
    load_parameters_to_df(json_file_name="./data/parameters_model.json")::DataFrame

Returns a DataFrame with all parameters to run the MDP.
In addition, this function is responsible for loading the  parameters
required for the ODE model and simulation setup.
---

### Input
- `json_file_name::String` -- (optional, default: `./data/parameters_model.json`) path of a .json file with parameters.

### Output
A DataFrame with the regarding parameters.

### Example
- ` df_par = load_parameters_to_df()`
"""
function load_parameters_to_df(
    json_file_name="./data/parameters_model.json"
)::DataFrame
    file_JSON = open(json_file_name, "r")
    parameters = file_JSON |> JSON.parse |> DataFrame
    close(file_JSON)
    return parameters
end
