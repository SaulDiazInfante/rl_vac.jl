
"""
    check_inventory_integrity(args::Dict{String,Any})::Bool

Checks the integrity of the inventory system by verifying the consistency of 
epidemic dynamics and stock-related conservative laws. This function ensures 
that the simulation state adheres to predefined constraints and logs warnings 
or errors when inconsistencies are detected.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"state"`: The current simulation state.
  - `"inventory_parameters"`: Parameters related to inventory management.
  - `"initial_condition"`: The initial conditions of the simulation.

# Returns
- `Bool`: Returns `true` if all integrity checks pass, otherwise `false`.

# Details
1. **Epidemic Dynamics Check**:
   - Verifies that the `Conservative_Law` field in the simulation state is 
     approximately equal to `1.0` within a specified tolerance.
   - Logs a warning if the condition is not met.

2. **Inventory Stock Check**:
   - Computes the stock-related conservative law (`CL_stock`) using the 
     current stock, cumulative vaccinations, and stock loss.
   - Compares `CL_stock` with the reorder point size from the initial 
     conditions.
   - Logs detailed information and warnings if the condition is not met.

3. **Index Validation**:
   - Ensures that the computed index for inventory projection does not exceed 
     the number of delivery time points. Throws an error if this condition is 
     violated.

4. **Logging**:
   - Saves the initial and current states to JSON files when inventory 
     inconsistencies are detected.
   - Logs detailed information about the current state, including time, stock, 
     vaccinations, and losses.

# Notes
- The function uses `isapprox` for approximate equality checks with specified 
  absolute and relative tolerances.
- If any of the checks fail, appropriate warnings or errors are logged, but 
  the function does not terminate the program unless the index validation 
  fails.

# Example
"""
function check_inventory_integrity(args::Dict{String,Any})::Bool
    new_state = copy(args["state"])
    inventory_par = copy(args["inventory_parameters"])
    stage_initial_condition = copy(args["initial_condition"])

    dim = length(fieldnames(structState))
    index = get_stencil_projection(new_state.time, inventory_par)
    n_deliveries = size(inventory_par.t_delivery, 1)
    if (index > n_deliveries)
        println("index $(index)")
        error("\n (---) ERROR simulation time Overflow ")
    end

    CL_new_dynamics = new_state.Conservative_Law
    CL_new_dynamics_cond = isapprox(
        CL_new_dynamics,
        1.0;
        atol=1e-12,
        rtol=0
    )

    if !CL_new_dynamics_cond
        @warn"\n (----) WARNING: Epidemic dynamics conservative law overflow"
    end

    stock_vaccine_reorder_point_size = stage_initial_condition.K_stock_t
    previous_stage_X_vac =
        stage_initial_condition.previous_stage_cumulative_vaccination
    previous_stage_vaccine_loss = stage_initial_condition.stock_loss

    new_K_stock = new_state.K_stock_t
    new_stage_X_vac = new_state.X_vac - previous_stage_X_vac
    new_stage_vaccine_loss = (
        new_state.stock_loss - previous_stage_vaccine_loss
    )

    CL_stock = new_K_stock + new_stage_X_vac + new_stage_vaccine_loss
    CL_stock_condition = isapprox(
        CL_stock,
        stock_vaccine_reorder_point_size;
        atol=1e-2,
        rtol=1e-2
    )
    if !CL_stock_condition
        df = save_state_to_json(
            stage_initial_condition,
            "log_current_state.json"
        )
        df_ = save_state_to_json(
            new_state,
            "log_new_state.json"
        )
        @info("(---) CL_stock: $(
                @sprintf("%.8f", CL_stock * POP_SIZE)
        )")

        @info("(---) reorder inventory size: $(
                @sprintf("%.8f", stock_vaccine_reorder_point_size * POP_SIZE)
        )")

        @info("\nt \t K_t\t\t X_vac\t\t l")
        @printf("%6.2f\t %10.2f\t %10.2f\t %10.2f\n",
            new_state.time,
            new_K_stock * POP_SIZE,
            new_stage_X_vac * POP_SIZE,
            new_stage_vaccine_loss * POP_SIZE
        )
        @warn"\n (---) Inventory  overflow "
    end
    CL_cond = CL_new_dynamics_cond & CL_stock_condition
    return CL_cond
end