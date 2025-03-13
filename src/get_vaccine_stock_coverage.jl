"""
    get_vaccine_stock_coverage(k, parameters)

Returns el percentage of population to vaccine when the inventory 
level of interest is k and use the current parameters 

# Arguments
- `k:: Float64:` Current fraction of the maximum vaccine-stock level 
- `parameters::DataFrame`: current parameters.
...
"""
function get_vaccine_stock_coverage(k, parameters)
    l_s = parameters.low_stock[1] / parameters.N[1]
    x_coverage = maximum([k - l_s, 0.0])
    return x_coverage
end
