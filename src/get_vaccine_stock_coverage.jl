"""
    get_vaccine_stock_coverage(args::Dict{String,Any})::Vector{Float64}

Calculate the vaccine stock coverage based on the current inventory size, backup inventory level, and population size.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"state"`: An object that includes the current inventory size (`K_stock_t`).
  - `"inventory_parameters"`: An object that includes the backup inventory level (`backup_inventory_level`).
  - `"model_parameters"`: An object that includes the population size (`N`).

# Returns
- `Vector{Float64}`: A vector containing the vaccine stock coverage value, which is the maximum of the difference between the current inventory size and the normalized backup inventory level, or 0.0.

# Notes
- The backup inventory level is normalized by dividing it by the population size.
- The function ensures that the stock coverage value is non-negative.
"""

function get_vaccine_stock_coverage(
    args::Dict{String,Any}
)::Float64
    state = args["state"]
    inventory_parameters = args["inventory_parameters"]
    backup_inventory_level = inventory_parameters.backup_inventory_level
    normalized_backup_inventory_level = backup_inventory_level / POP_SIZE
    current_inventory_size = state.K_stock_t
    x_coverage = maximum([
        current_inventory_size - normalized_backup_inventory_level,
        0.0
    ])
    return x_coverage
end
