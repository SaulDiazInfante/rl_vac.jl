"""
    get_max_vaccination_rate!(vaccine_coverage::Float64, args::Dict{String,Any})::Float64

Calculate the maximum vaccination rate given the current vaccine coverage and model parameters.

# Arguments
- `vaccine_coverage::Float64`: The desired vaccine coverage as a fraction (e.g., 0.7 for 70%).
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"state"`: The current state of the system, which includes the current time `t`.
  - `"inventory_parameters"`: A dictionary containing inventory-related parameters, including delivery times.
  - `"model_parameters"`: A dictionary containing model-specific parameters, which will be updated with the calculated vaccination rate.

# Returns
- `Float64`: The maximum vaccination rate calculated based on the given parameters.

# Behavior
- The function computes the vaccination rate required to achieve the desired vaccine coverage within the remaining time interval.
- If the calculated vaccination rate is negative, it is clamped to `0.0`.
- Updates the `"model_parameters"` dictionary in `args` with the computed vaccination rate (`psi_v`).
- Logs a warning if the vaccination rate is approximately zero.

# Notes
- The function modifies the `args` dictionary in-place by updating the `"model_parameters"` key.
- The function assumes that the `state.t` and `inventory_parameters.t_delivery` are properly defined and accessible.
"""


function get_max_vaccination_rate!(
    vaccine_coverage::Float64, args::Dict{String,Any}
)::Float64
    state = args["state"]
    inventory_par = args["inventory_parameters"]
    mod_par = args["model_parameters"]
    id = get_stencil_projection(state.time, inventory_par)
    NUM_DELIVERY = length(inventory_par.t_delivery)
    idx = min(id + 1, NUM_DELIVERY)
    t_horizon = inventory_par.t_delivery[idx]
    t_interval_len = t_horizon - state.time

    if isapprox(1e-20, t_interval_len; atol=eps(Float64), rtol=0)
        @warn "Warning: time interval length is zero or less than eps(Float64)"
        @info "Then we set vaccination rate interval is zero — setting rate to"
        max_vaccination_rate = 0.0
    else
        psi_v = -log(1.0 - vaccine_coverage) / t_interval_len
        max_vaccination_rate = max(0.0, psi_v)
    end

    mod_par.psi_v = max_vaccination_rate
    if isapprox(1e-20, max_vaccination_rate; atol=eps(Float64), rtol=0)
        @warn "Warning: zero vaccination rate estimated"
    end
    args["model_parameters"] = mod_par
    return max_vaccination_rate
end