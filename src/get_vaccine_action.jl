"""
    get_vaccine_action!(X_c, t, parameters)

Returns a vaccine action.
This descision is calcualted in order to
reach after a horizont time t_horizon a coverage X_C.
    
# Arguments
- `X_c::Float`: Current coverage population at time t
- `t::Float`: time
- `parameters::DataFrame`: current parameters.
...
"""
function get_vaccine_action!(X_C, t, parameters)
    id = get_stencil_projection(t, parameters)
    t_initial_interval = parameters.t_delivery[id-1]
    t_horizon = t - t_initial_interval
    psi_v = -log(1.0 - X_C) / (t_horizon)
    a_t = max(0.0, psi_v)
    parameters.psi_v[id-1] = psi_v
    if isapprox(1e-20, a_t; atol=eps(Float64), rtol=0)
        print("Warning: zero vaccination rate estimated")
    end
    return a_t
end