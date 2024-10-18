"""
    load_parameters(json_file_name="./data/parameters_model.json")

Returns a DataFrame with all parameters to run the MDP.
In addition, this function is responsible for loading the  parameters
required for the ODE model and simulation configuration.
---
# Arguments
- `json_file_name::String`: Path of a .json file with parameters.
"""
function load_parameters(json_file_name="./data/parameters_model.json")
    file_JSON = open(json_file_name, "r")
    parameters = file_JSON |> JSON.parse |> DataFrame;
    close(file_JSON)
    return parameters
end
