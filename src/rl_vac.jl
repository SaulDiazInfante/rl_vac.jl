"""
Module for simulation of a Vaccine stock Management with 
Markov Decision Processes. See
(https://www.overleaf.com/read/hqmrsgtnfvkh)[https://www.overleaf.com/read/hqmrsgtnfvkh]
to details.
"""
module rl_vac
#=
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
=#
using JSON, JSON3, DataFrames, Distributions
using CSV, LaTeXStrings, PlotlyJS
using Dates, ProgressMeter, Interpolations
using CairoMakie, StatsBase, MakiePublication, Printf
using Debugger, Random
#

include("rl_vac_types.jl")

export structState
export structModelParameters
export structNumericSolverParameters
export structInventoryParameters

export load_parameters_to_df
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
export compute_mr_ou_temp_loss
export compute_nsfd_iteration!
export tag_file
export interpolate_mc_paths
export optimize_interval_solution
export get_initial_condition
export json_to_struct
#
include("load_parameters_to_df.jl")
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
include("compute_mr_ou_temp_loss.jl")
include("compute_nsfd_iteration.jl")
include("tag_file.jl")
include("interpolate_mc_paths.jl")
include("optimize_interval_solution.jl")
include("get_initial_condition.jl")
include("json_to_struct.jl")
end
