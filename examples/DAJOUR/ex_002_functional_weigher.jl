using rl_vac
using Test, ProgressMeter
using DataFrames, CSV, JSON
using Dates

sampling_size = 100
json_file_name = "data/parameters_model.json"

parameters = load_parameters(json_file_name);

stock_cost_weight = parameters[:, "stock_cost_weight"];
campaign_cost_weight = parameters[:, "campaign_cost_weight"];
yld_weight = parameters[:, "yld_weight"];
yll_weight = parameters[:, "yll_weight"];

x0, df = get_solution_path!(parameters);
#
# 
df_par = DataFrame();
df_samples = DataFrame();
#
idx_path_par = ones(Int64, size(parameters)[1]);
idx_path = ones(Int64, size(df)[1]);
#
insertcols!(parameters, 31, :idx_path => idx_path_par);
insertcols!(df, 13, :idx_path => idx_path);
df_samples = [df_samples; df];
df_par = [df_par; parameters];
par = copy(parameters);
# 
raise_factor = 2.0
par[:, :stock_cost_weight] = raise_factor * par[:, :stock_cost_weight]
# here we postulate candidates for weights
n = sampling_size
p = Progress(n, 1, "Sampling")
#
#
for idx in 2:sampling_size
    # postulate new parameters raising with a diadic rational
    par[:, :stock_cost_weight] =
        (raise_factor^idx) * par[:, :stock_cost_weight]
    x0, df = get_solution_path!(par)
    idx_path_par = idx * ones(Int64, size(par)[1])
    idx_path = idx * ones(Int64, size(df)[1])
    par[:, :idx_path] = idx_path_par
    insertcols!(df, 13, :idx_path => idx_path)
    df_par = [df_par; par]
    df_samples = [df_samples; df]
    next!(p)
end
# saving par time seires
prefix_file_name = "df_par_weights"
#
d = Dates.now()
tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
suffix_file_name = ".csv"
csv_file_name = prefix_file_name * tag * suffix_file_name
path_par = "./data/" * csv_file_name
CSV.write(path_par, df_par)
# 
prefix_file_name = "df_samples_weight"
csv_file_name = prefix_file_name * suffix_file_name
path_weight_sample = "./data/" * csv_file_name
CSV.write(path_weight_sample, df_samples)