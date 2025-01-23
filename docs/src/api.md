# API

```@docs

load_parameters
get_stencil_projection
rhs_evaluation!
get_stochastic_perturbation
compute_cost
get_vaccine_stock_coverage
get_vaccine_action!
get_interval_solution!
get_solution_path!
save_interval_solution
montecarlo_sampling
get_interpolated_solution
get_simulation_statistics
get_panel_plot
get_confidence_bands
get_epidemic_states_confidence_bands
get_deterministic_plot_path(
    df_mc::DataFrame,
    pop_size::Float64,
    file_name_f1::AbstractString,
    file_name_f2::AbstractString
)
```

## With autodocs

```@autodocs
Modules = [rl_vac]
Order = [:function, :type]
pages = [
    "load_parameters.jl",
    "get_stencil_projection.jl",
    "rhs_evaluation.jl",
    "get_stochastic_perturbation.jl",
    "compute_cost.jl",
    "get_vaccine_stock_coverage.jl",
    "get_vaccine_action.jl",
    "get_interval_solution.jl",
    "get_solution_path.jl",
    "save_interval_solution.jl",
    "montecarlo_sampling.jl",
    "get_interpolated_solution.jl",
    "get_simulation_statistics.jl",
    "get_panel_plot.jl",
    "get_confidence_bands.jl",
    "get_epidemic_states_confidence_bands.jl",
    "get_deterministic_plot_path.jl"
]
```
