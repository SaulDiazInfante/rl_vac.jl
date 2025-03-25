"""
    get_interpolated_solution(trajectory::DataFrame, line_time)
    interpolated a sampled path of the solution process 
    respect a given interval time with line_time

# Arguments
- `trajectory::DataFrame`: Solution path to interpolate.
- `line_time::Vector`: Time points for interpolation
...
"""
function get_interpolated_solution(trajectory::DataFrame, line_time)
    state_names = [
        "time", "S", "E", "I_S",
        "I_A", "R", "D", "V",
        "CL", "X_vac", "X_0_mayer", "K_stock",
        "T", "loss", "action", "opt_policy"
    ]
    par = load_parameters_to_df()
    k = par.low_stock[1] / par.N[1]
    trajectory_time = trajectory.time
    trajectory_time = unique(sort(trajectory_time))
    dim = [length(line_time), length(state_names)]
    interpolated_time_states = zeros(dim[1], dim[2])
    interpolated_time_states[:, 1] = line_time
    df = DataFrame(interpolated_time_states, state_names)
    for state_name in state_names[2:end]
        state = trajectory[!, Symbol(state_name)]
        interpolated_state = linear_interpolation(
            trajectory_time, state, extrapolation_bc=Line())
        interpolated_state_eval = interpolated_state.(line_time)
        df[!, Symbol(state_name)] = interpolated_state_eval
    end
    return df
end