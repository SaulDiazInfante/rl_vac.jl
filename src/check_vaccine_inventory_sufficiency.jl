"""
    check_vaccine_inventory_sufficiency(current_args::Dict{String,Any}, new_state::structState) :: Bool

Checks whether the vaccine inventory is sufficient to meet the new demand and losses while maintaining a reserve inventory.

# Arguments
- `current_args::Dict{String,Any}`: A dictionary containing the current state and parameters of the system. 
  - Keys include:
    - `"state"`: The current state of the system.
    - `"inventory_parameters"`: Parameters related to inventory management.
    - `"initial_condition"`: The initial condition of the system.
- `new_state::structState`: The new state of the system, which includes updated vaccine demand and stock loss.

# Returns
- `Bool`: `true` if the vaccine inventory is sufficient to meet the new demand and losses while maintaining the reserve inventory, otherwise `false`.

# Details
- The function calculates the new vaccine demand and losses based on the difference between the new state and the initial condition.
- It computes the reserve inventory level using normalized parameters and compares it with the current stock.
- The function ensures that the available stock is greater than the new demand and that the available stock is not approximately equal to the sum of the new demand and losses, within a specified tolerance.

# Notes
- The `POP_SIZE` constant is assumed to be defined elsewhere in the codebase.
- The `isapprox` function is used to check for approximate equality with an absolute tolerance (`atol`) of `1e-12` and a relative tolerance (`rtol`) of `0`.
"""
function check_vaccine_inventory_sufficiency(
    current_args::Dict{String,Any},
    new_state::structState
)::Bool
    current_state = current_args["state"]
    inventory_par = copy(current_args["inventory_parameters"])
    stage_initial_condition = copy(current_args["initial_condition"])

    new_demand = new_state.X_vac - current_state.X_vac
    new_vaccine_loss = new_state.stock_loss - current_state.stock_loss

    nominal_reserve_inventory = inventory_par.backup_inventory_level
    normalized_reserve_inventory =
        nominal_reserve_inventory / POP_SIZE
    reserve_inventory = normalized_reserve_inventory
    current_stock = current_state.K_stock_t

    available_sock = current_stock - reserve_inventory
    new_demand_and_loss = new_demand + new_vaccine_loss
    is_vaccine_demand_satisfied = (
        (available_sock > new_demand)
        &&
        !isapprox(
            available_sock,
            new_demand_and_loss,
            atol=1e-12,
            rtol=0
        )
    )
    return is_vaccine_demand_satisfied
end