"""
    adapt_vaccination_rate_to_inventory!(current_args::Dict{String,Any})::Dict{String,Any}

Adjusts the vaccination rate based on the current vaccine inventory and updates the model parameters 
and state accordingly. This function ensures that the vaccination rate does not exceed the available 
vaccine stock and recalibrates the rate to avoid inventory overflow.

# Arguments
- `current_args::Dict{String,Any}`: A dictionary containing the current state and model parameters. 
  Expected keys include:
  - `"state"`: The current state of the system.
  - `"model_parameters"`: The parameters of the vaccination model.

# Returns
- `Dict{String,Any}`: The updated state after recalibrating the vaccination rate.

# Workflow
1. Extracts the current state and model parameters from `current_args`.
2. Logs warnings and information about vaccine inventory overflow and recalibration.
3. Computes the vaccine stock coverage and determines the maximum allowable vaccination rate.
4. Updates the vaccination rate (`psi_v`) in the model parameters and the action in the current state.
5. Projects the number of vaccinations (jabs) based on the recalibrated rate.
6. Logs detailed information about the recalibration process, including normalized and nominal vaccination rates, 
   current stock, and projected vaccinations.
7. Computes the next state using a numerical method (`compute_nsfd_iteration!`).

# Notes
- The function assumes the existence of helper functions such as `get_vaccine_stock_coverage`, 
  `get_max_vaccination_rate!`, and `compute_nsfd_iteration!`.
- The function logs detailed information for debugging purposes, including time intervals and stock levels.
"""
function adapt_vaccination_rate_to_inventory!(
    current_args::Dict{String,Any}
)::Vector{Float64}
    current_state = current_args["state"]
    inventory_par = current_args["inventory_parameters"]
    mod_par = current_args["model_parameters"]
    @warn"\n(===): reserve vaccine inventory overflow"
    @info "\n(+++) Recalibrating the vaccination rate: "

    log_path = joinpath(dirname(@__DIR__), "logs/")
    arg_tag =
        Dict(
            "path" => log_path,
            "prefix_file_name" => "recalibration_",
            "suffix_file_name" => ".json"
        )
    file_name = tag_file(arg_tag)
    save_state_to_json(current_state, file_name)

    vaccine_coverage = get_vaccine_stock_coverage(current_args)
    vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, current_args)

    action = max(0.0, vaccination_rate)
    mod_par.psi_v = vaccination_rate
    current_state.action = action
    projected_jabs = vaccine_coverage

    scaled_psi_v = vaccination_rate * POP_SIZE
    msg_01 = "\n\t normalized Psi_V: $(@sprintf("%.8f", vaccination_rate))"
    msg_02 = "\n\t nominal Psi_V: $(
                    @sprintf("%8.3f", scaled_psi_v
            )
    )"
    print("\n===========================================")
    index = get_stencil_projection(current_state.time, inventory_par)
    current_stock = current_state.K_stock_t
    t_lower = current_state.time
    t_upper = inventory_par.t_delivery[index+1]
    print("\nt_lower: ", t_lower)
    print("\nt_upper: ", t_upper)
    length_interval = t_upper - t_lower
    print("\nlength_interval$(@sprintf("%5.2f", length_interval))")
    print(msg_01)
    print(msg_02)
    print("\nActual stock:
         $(@sprintf("%8.3f", current_stock * POP_SIZE))
    ")

    print("\n\t Projected Jabs: $(
                @sprintf(
                    "%4.2f",
                    projected_jabs * length_interval * POP_SIZE
                )
            )")
    print("\n-------------------------------------------\n")
    x_new = compute_nsfd_iteration!(
        current_args
    )
    return x_new
end