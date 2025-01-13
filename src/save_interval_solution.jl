"""
    save_interval_solution(time, x;
        header_strs =
            ["time", "S", "E",
            "I_S", "I_A", "R",
            "D", "V", "CL",
            "X_vac", "K_stock", "action"],
        file_name = "solution_interval.csv"
        )

Return and save the state of model on discrete time values between time arrive deliveries.       

# Arguments
- `time::Vector`: Discrete time values where the system state is approximate.  
- `x::DataFrame`: System current state
- `header_strs::Vector`: action, that is a proportion of the total jabs projected
  that would be administrated.
- `k::Float`: current level of the vaccine-stock.
- `parameters::DataFrame`: current parameters.
...
"""
function save_interval_solution(x;
                header_strs =
                    [
                        
                        "time", "S", "E",
                        "I_S", "I_A", "R",
                        "D", "V", "CL",
                        "X_vac", "X_0_mayer", "K_stock",
        "action", "opt_policy",
        "t_index_interval"
                    ],
                file_name = "solution_interval.csv"
)
    data = x
    df_solution = (
        DataFrame(
            Dict(
                zip(
                    header_strs,
                    [data[:, i] for i in 1:size(data, 2)]
                )
            )
        )
    )
    CSV.write(file_name, df_solution)
    return df_solution;
end
