"""
    get_stochastic_perturbation(json_file_name="../data/parameters_model.json")::DataFrame

Returns a random perturbation of the delivery plan enclosed
in the json file. To do this, the function loads the
parameters as the DataFrame `par` and then sum to the 
deliveries times and stock shipments a random
variable.

### Keyword arguments

- `json_file_name::String` = "../data/parameters_model.json".
Path with the `.json` file with setup parameters.

"""

function get_stochastic_perturbation(
    json_file_name="../data/parameters_model.json"
)::DataFrame

    par = load_parameters_to_df(json_file_name)
    t_delivery = par.t_delivery
    delivery_size_k = par.delivery_size_k
    aux_t = zeros(length(t_delivery))
    aux_k = zeros(length(t_delivery))
    aux_k[1] = delivery_size_k[1]
    aux_t[1] = t_delivery[1]
    deltaction_t = 0.0

    #
    for t in eachindex(t_delivery[1:end-1])
        aux_t_ = t_delivery[t]
        aux_k_ = delivery_size_k[t+1]
        etaction_t = Truncated(
            Normal(
                aux_k_,
                0.5 * sqrt(aux_k_)
            ),
            0, 2 * aux_k_
        )
        xi_t = rand(etaction_t, 1)[1]
        aux_k[t+1] = xi_t
        #
        deltaction_t = t_delivery[t+1] - t_delivery[t]
        tau = Normal(deltaction_t, 1.0 * sqrt(deltaction_t))
        deltaction_tau = rand(tau, 1)[1]
        aux_t[t+1] = aux_t_ + deltaction_tau
    end
    par.t_delivery = aux_t
    par.delivery_size_k = aux_k
    return par
end
