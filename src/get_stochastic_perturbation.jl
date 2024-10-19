"""
    get_stochastic_perturbation(json_file_name="../data/parameters_model.json")

Returns a random perturabation of the delivery plan enclosed in the json
file. To do this, the function loads the parameters as the dataframe
`par` and then sum to the deliveries times and stock shimpments a random
variable.

---
"""
function get_stochastic_perturbation(
    json_file_name="../data/parameters_model.json"
)
    par = load_parameters(json_file_name)
    t_delivery = par.t_delivery
    k_stock = par.k_stock
    aux_t = zeros(length(t_delivery))
    aux_k = zeros(length(t_delivery))
    delta_t = 0.0
    t = 1
    aux_t[t] = t_delivery[t]
    aux_k[t] = k_stock[t]
    for t in 2:length(t_delivery)
        eta_t = Truncated(
            Normal(
                k_stock[t],
                0.5 * sqrt(k_stock[t])
            ),
            0, 2 * k_stock[t]
        )
        delta_t = t_delivery[t] - t_delivery[t-1]
        tau = Normal(delta_t, 1.0 * sqrt(delta_t))
        # tau = Uniform(.25 * delta_t, 1.5 * delta_t) 
        # tau = Exponential(64.0); 
        delta_tau = rand(tau, 1)[1]
        # aux_t[t] = aux_t[t-1] + delta_t * (1.0 + rand(u, 1)[1])  
        aux_t[t] = aux_t[t-1] + delta_tau
        xi_t = rand(eta_t, 1)[1]
        aux_k[t] = xi_t
    end
    par.t_delivery = aux_t
    par.k_stock = aux_k
    return par
end
# Benchmark
#= df_sto_time = DataFrame() 
insertcols!(df_sto_time, 1, :time => par.t_delivery);
insertcols!(df_sto_time, 1, :index => 1);

for j in 1:1000
    sample_j = DataFrame()
    par = get_stochastic_perturbation()
    insertcols!(sample_j, 1, :time => par.t_delivery);
    insertcols!(sample_j, 1, :index => j);
    df_sto_time = [df_sto_time; sample_j]
end

df_sto_time
 =#
