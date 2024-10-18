"""
Module for simulation of a Vaccine stock Management with 
Markov Decission Processes. See
(https://www.overleaf.com/read/hqmrsgtnfvkh)[https://www.overleaf.com/read/hqmrsgtnfvkh]
to details.
"""
module rl_vac
using JSON, DataFrames, Distributions
using CSV, LaTeXStrings
using Dates, ProgressMeter, Interpolations
using CairoMakie, StatsBase, MakiePublication
#
export load_parameters
export get_stencil_projection
export load_parameters
export get_stencil_projection
export rhs_evaluation!
export get_stochastic_perturbation
export compute_cost
export get_vaccine_stock_coverage
export get_vaccine_action!
export get_interval_solution!
export get_solution_path!
export save_interval_solution
export montecarlo_sampling
export get_interpolated_solution
export get_simulation_statistics
export get_panel_plot
export get_confidence_bands
export get_epidemic_states_confidence_bands
export get_deterministic_plot_path
#
include("load_parameters.jl")
include("get_stencil_projection.jl")
include("rhs_evaluation.jl")
include("get_stochastic_perturbation.jl")
include("compute_cost.jl")
include("get_vaccine_stock_coverage.jl")
include("get_vaccine_action.jl")
include("get_interval_solution.jl")
include("get_solution_path.jl")
include("save_interval_solution.jl")
include("montecarlo_sampling.jl")
include("get_interpolated_solution.jl")
include("get_simulation_statistics.jl")
include("get_panel_plot.jl")
include("get_confidence_bands.jl")
include("get_epidemic_states_confidence_bands.jl")
include("get_deterministic_plot_path.jl")
end
