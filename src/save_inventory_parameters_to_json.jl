"""
    save_inventory_parameters_to_json(state::structState, filename::String) -> DataFrame

Saves the parameters of an inventory system represented by a `structState` object to a JSON file.

# Arguments
- `state::structState`: The state object containing inventory parameters.
- `filename::String`: The path to the JSON file where the inventory parameters will be saved.

# Returns
- `DataFrame`: A DataFrame representation of the inventory parameters.

# Details
This function extracts the fields of the `structInventoryParameters` type from the given `state` object,
converts them into a dictionary, and writes the dictionary to a JSON file specified by `filename`.
Additionally, it returns a DataFrame containing the same data for further use.

# Example
"""

StructTypes.StructType(::Type{structInventoryParameters}) = StructTypes.Struct()
function save_inventory_parameters_to_json(
    inventory_parameters::structInventoryParameters, filename::String
)
    function pad_to_match_length(arr, target_length)
        return vcat(arr, fill(missing, target_length - length(arr)))
    end

    max_length = maximum(
        length.(
            [
            inventory_parameters.backup_inventory_level,
            inventory_parameters.t_delivery,
            inventory_parameters.delivery_size_k,
            inventory_parameters.yll_weight,
            inventory_parameters.yld_weight,
            inventory_parameters.stock_cost_weight,
            inventory_parameters.campaign_cost_weight,
            inventory_parameters.operational_stock_levels
        ]
        )
    )
    backup_inventory_level = pad_to_match_length(
        inventory_parameters.backup_inventory_level,
        max_length
    )
    t_delivery = pad_to_match_length(
        inventory_parameters.t_delivery,
        max_length
    )
    delivery_size_k = pad_to_match_length(
        inventory_parameters.delivery_size_k,
        max_length
    )
    yll_weight = pad_to_match_length(
        inventory_parameters.yll_weight,
        max_length
    )
    yld_weight = pad_to_match_length(
        inventory_parameters.yld_weight,
        max_length
    )
    stock_cost_weight = pad_to_match_length(
        inventory_parameters.stock_cost_weight,
        max_length
    )

    campaign_cost_weight = pad_to_match_length(
        inventory_parameters.campaign_cost_weight,
        max_length
    )

    operational_stock_levels = pad_to_match_length(
        inventory_parameters.operational_stock_levels,
        max_length
    )


    dict_par = Dict(
        "backup_inventory_level" => backup_inventory_level,
        "t_delivery" => t_delivery,
        "delivery_size_k" => delivery_size_k,
        "yll_weight" => yll_weight,
        "yld_weight" => yld_weight,
        "stock_cost_weight" => stock_cost_weight,
        "campaign_cost_weight" => campaign_cost_weight,
        "operational_stock_levels" => operational_stock_levels
    )
    df = DataFrame(dict_par)

    JSON3.write(filename, dict_par)
    return df
end



