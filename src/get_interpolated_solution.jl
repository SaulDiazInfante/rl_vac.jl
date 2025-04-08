"""
    get_interpolated_solution(trajectory::DataFrame, time_line)
    interpolated a sampled path of the solution process 
    respect a given interval time with time_line

# Arguments
- `trajectory::DataFrame`: Solution path to interpolate.
- `time_line::Vector`: Time points for interpolation
...
"""
function get_interpolated_solution(trajectory::DataFrame, time_line)
    state_names = [
        "time", "S", "E", "I_S",
        "I_A", "R", "D", "V",
        "CL", "X_vac", "X_0_mayer", "K_stock_t",
        "T", "loss", "action", "opt_policy"
    ]
    par = load_parameters_to_df()
    trajectory_time = trajectory.time
    trajectory_time = unique(sort(trajectory_time))
    dim = [length(time_line), length(state_names)]
    interpolated_time_states = zeros(dim[1], dim[2])
    interpolated_time_states[:, 1] = time_line
    df = DataFrame(interpolated_time_states, state_names)
    for state_name in state_names[2:end]
        state = trajectory[!, Symbol(state_name)]
        interpolated_state = linear_interpolation(
            trajectory_time, state, extrapolation_bc=Line())
        interpolated_state_eval = interpolated_state.(time_line)
        df[!, Symbol(state_name)] = interpolated_state_eval
    end
    return df
end