"""
    get_stochastic_perturbation(args::Dict{String,Any})::Vector{Tuple{Float64,Float64}}

Generates a stochastic perturbation for inventory delivery times and sizes based on the input parameters.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the inventory parameters under the key `"inventory_parameters"`. 
  The inventory parameters should include:
  - `t_delivery`: A vector of delivery times.
  - `delivery_size_k`: A vector of delivery sizes.

# Returns
- `Vector{Tuple{Float64,Float64}}`: A vector of tuples where each tuple represents a perturbed delivery time and size.

# Details
The function perturbs the delivery times and sizes using truncated normal distributions:
- Delivery times are perturbed based on the difference between consecutive times (`delta_t`) with a standard deviation proportional to the square root of `delta_t`.
- Delivery sizes are perturbed based on their original values with a standard deviation proportional to the square root of the size.

The perturbed values are constrained to be within `[0, 2 * original_value]` using a truncated normal distribution.

# Side Effects
- Updates the `t_delivery` and `delivery_size_k` fields in the `inventory_parameters` dictionary within `args`.

# Example
"""
function get_stochastic_perturbation!(
    args::Dict{String,Any}
)::Vector{Tuple{Float64,Float64}}

    inventory_par = args["inventory_parameters"]
    t_delivery = inventory_par.t_delivery
    delivery_size_k = inventory_par.delivery_size_k
    aux_t = zeros(length(t_delivery))
    aux_k = zeros(length(t_delivery))
    aux_k[1] = delivery_size_k[1]
    aux_t[1] = t_delivery[1]
    aux_t[end] = t_delivery[end]
    delta_t = 0.0

    for t in eachindex(t_delivery[1:end-2])
        aux_t_ = t_delivery[t]
        delta_t = t_delivery[t+1] - t_delivery[t]
        tau = Truncated(
            Normal(
                delta_t, 0.5 * sqrt(delta_t)
            ), 0, 2 * delta_t
        )
        delta_tau = rand(tau, 1)[1]
        aux_t[t+1] = aux_t_ + delta_tau

        aux_k_ = delivery_size_k[t+1]
        eta_k = Truncated(
            Normal(
                aux_k_,
                0.5 * sqrt(aux_k_)
            ),
            0, 2 * aux_k_
        )
        xi_t = rand(eta_k, 1)[1]
        aux_k[t+1] = xi_t
    end
    new_reorder_points = [point for point in zip(aux_t, aux_k)]
    inventory_par.t_delivery = aux_t
    inventory_par.delivery_size_k = aux_k
    args["inventory_parameters"] = inventory_par
    return new_reorder_points
end
