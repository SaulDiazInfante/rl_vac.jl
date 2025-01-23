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

    par = load_parameters(json_file_name)
    t_delivery = par.t_delivery
    k_stock = par.k_stock
    aux_t = zeros(length(t_delivery))
    aux_k = zeros(length(t_delivery))
    delta_t = 0.0
    #
    for t in eachindex(t_delivery[1:end-1])
        aux_t_ = t_delivery[t]
        aux_k_ = k_stock[t+1]
        eta_t = Truncated(
            Normal(
                aux_k_,
                0.5 * sqrt(aux_k_)
            ),
            0, 2 * aux_k_
        )
        xi_t = rand(eta_t, 1)[1]
        aux_k[t] = xi_t
        #
        delta_t = t_delivery[t+1] - t_delivery[t]
        tau = Normal(delta_t, 1.0 * sqrt(delta_t))
        delta_tau = rand(tau, 1)[1]
        aux_t[t+1] = aux_t_ + delta_tau
    end
    par.t_delivery = aux_t
    par.k_stock = aux_k
    return par
end
