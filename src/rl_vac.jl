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
using JSON, JSON3, DataFrames
using StructTypes, Distributions
using CSV, LaTeXStrings, PlotlyJS
using Dates, ProgressMeter, Interpolations
using CairoMakie, StatsBase, MakiePublication, Printf
using Random, Revise
using Logging
#

include("rl_vac_types.jl")
include("constants.jl")

export structState
export structModelParameters
export structNumericSolverParameters
export structInventoryParameters
export POP_SIZE
export N_GRIDE_SIZE

export load_parameters_to_df
export get_stencil_projection
export rhs_evaluation!
export get_stochastic_perturbation!
export compute_cost
export get_vaccine_stock_coverage
export get_max_vaccination_rate!
export get_stage_solution!
export get_solution_path!
export save_interval_solution
export generate_montecarlo_samples
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
export optimize_stage_solution!
export get_initial_condition
export json_to_struct
export build_testing_parameters
export get_struct_values
export build_interval_stencil!
export process_first_inventory_reorder_point!
export process_inventory_reorder_point!
export save_state_to_csv
export save_state_to_json
export save_inventory_parameters_to_json
export load_state_from_json
export save_solution_path
export log_to_file
export check_inventory_integrity
export check_vaccine_inventory_sufficiency
export adapt_vaccination_rate_to_inventory!
export setup_mc_simulation
#
include("load_parameters_to_df.jl")
include("get_stencil_projection.jl")
include("rhs_evaluation.jl")
include("get_stochastic_perturbation.jl")
include("compute_cost.jl")
include("get_vaccine_stock_coverage.jl")
include("get_max_vaccination_rate.jl")
include("get_stage_solution.jl")
include("get_solution_path.jl")
include("save_interval_solution.jl")
include("generate_montecarlo_samples.jl")
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
include("optimize_stage_solution.jl")
include("get_initial_condition.jl")
include("json_to_struct.jl")
include("build_testing_parameters.jl")
include("get_struct_values.jl")
include("build_interval_stencil.jl")
include("process_first_inventory_reorder_point.jl")
include("process_inventory_reorder_point.jl")
include("save_state_to_csv.jl")
include("save_state_to_json.jl")
include("load_state_from_json.jl")
include("save_solution_path.jl")
include("log_to_file.jl")
include("check_inventory_integrity.jl")
include("check_vaccine_inventory_sufficiency.jl")
include("adapt_vaccination_rate_to_inventory.jl")
include("save_inventory_parameters_to_json.jl")
include("setup_mc_simulation.jl")
end
