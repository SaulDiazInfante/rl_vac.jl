"""
    get_stencil_projection(t::Float64, par::structInventoryParameters) -> Int64

Computes the stencil projection for a given time `t` and a parameter structure `par`.

# Arguments
- `t::Float64`: The time value for which the stencil projection is computed.
- `par::structInventoryParameters`: A structure containing inventory parameters, 
  including `t_delivery`, which is used as the stencil.

# Returns
- `Int64`: The maximum index from the grid where the condition `t .>= stencil` is satisfied.

# Notes
- The function uses `findall` to locate all indices where the condition is true.
- The `maximum` function is applied to the resulting indices to determine the projection.
"""

function get_stencil_projection(t::Float64, par::structInventoryParameters)::Int64
    stencil = par.t_delivery
    grid = findall(t .>= stencil)
    projection = maximum(grid)
    return projection
end
