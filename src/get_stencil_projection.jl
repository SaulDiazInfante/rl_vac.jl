"""
    get_stencil_projection(t::Float64, parameters::DataFrame)::Float64

Returns the index of corresponding projection of time t to the stencil and in accordance with the parameters vector.

# Arguments
- `t::Float64`: time to project to the stencil
- `parameters::DataFrame`: Data Frame loaded with 
    `load_parameters(...)` function 
---
"""
function get_stencil_projection(t::Float64, parameters::DataFrame)::Float64
    stencil = parameters.t_delivery
    grid = findall(t .>= stencil)
    projection = maximum(grid)
    return projection
end
