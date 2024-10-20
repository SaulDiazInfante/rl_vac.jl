"""
    get_interpoled_solution(trajectory::DataFrame, line_time)
    iterpolate a sampled path of the solution process 
    respect a given interval time with line_time

# Arguments
- `trajectory::DataFrame`: Solution path to invterpolate.
- `line_time::Vector`: Time points for interpolation
...
"""
function get_interpolated_solution(trajectory::DataFrame, line_time)
    state_names = [
        "time",
        "D", "E", "I_A", "I_S", "K_stock",
        "R", "S", "V", "X_vac", "action"
    ]
    par = load_parameters()
    k = par.low_stock / par.N
    k = k[1]
    time = trajectory.time
    dim = [length(line_time), length(state_names)]
    interpolated_time_states = zeros(dim[1], dim[2])
    interpolated_time_states[:, 1] = line_time
    df = DataFrame(interpolated_time_states, state_names)
    for state_name in state_names
        state = trajectory[!, Symbol(state_name)]
        interpolated_state = linear_interpolation(
            time, state, extrapolation_bc=Line())
        interpolated_state_eval = interpolated_state.(line_time)
        if state_name == "K_stock"
            K = k * ones(length(interpolated_state_eval))
            aux = [interpolated_state_eval'; K']
            interpolated_state_eval = maximum(aux, dims=1)[:]
        end
        df[!, Symbol(state_name)] = interpolated_state_eval
    end
    return df
end