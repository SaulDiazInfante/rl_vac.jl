"""
    compute_cost(args::Dict{String,Any})::Float64

Compute the total cost based on the provided arguments.

# Arguments
- `args::Dict{String,Any}`: A dictionary containing the following keys:
  - `"initial_condition"`: An object representing the initial state of the system.
  - `"state"`: An object representing the current state of the system.
  - `"model_parameters"`: An object containing model parameters such as `p`, `delta_e`, `theta`, and `alpha_s`.
  - `"inventory_parameters"`: An object containing inventory parameters such as `yll_weight`, `yld_weight`, `stock_cost_weight`, and `campaign_cost_weight`.

# Returns
- `Float64`: The computed total cost, which is the sum of the following components:
  - `yll`: The cost associated with years of life lost (YLL), weighted by `yll_weight`.
  - `yld`: The cost associated with years lived with disability (YLD), weighted by `yld_weight`.
  - `stock_cost`: The cost associated with stock changes, weighted by `stock_cost_weight`.
  - `campaign_cost`: The cost associated with vaccination campaigns, weighted by `campaign_cost_weight`.

# Details
The function calculates the cost components based on the difference between the current state and the initial condition, using the provided model and inventory parameters. The total cost is the sum of these components.
"""
function compute_cost(args::Dict{String,Any})::Float64
    initial_condition = args["initial_condition"]
    state = args["state"]
    mod_par = args["model_parameters"]
    inventory_par = args["inventory_parameters"]


    m_yll = inventory_par.yll_weight[1]
    m_yld = inventory_par.yld_weight[1]
    m_stock_cost = inventory_par.stock_cost_weight[1]
    m_campaign_cost = inventory_par.campaign_cost_weight[1]


    E = state.E
    E_0 = initial_condition.E
    K_stock_t = state.K_stock_t
    K_stock_t_0 = initial_condition.K_stock_t

    X_vac = state.X_vac
    X_vac_0 = initial_condition.X_vac

    p = mod_par.p
    delta_e = mod_par.delta_e
    theta = mod_par.theta
    alpha_s = mod_par.alpha_s

    yll = m_yll * p * delta_e * (E - E_0)
    yld = m_yld * theta * alpha_s * (E - E_0)
    stock_cost = m_stock_cost * (K_stock_t - K_stock_t_0)
    campaign_cost = m_campaign_cost * (X_vac - X_vac_0)
    cost = sum([yll, yld, stock_cost, campaign_cost])
    return cost
end