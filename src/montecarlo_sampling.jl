"""
    montecarlo_sampling(sampling_size=10000,
    json_file_name="parameters_model.json")

Given sampling size  and a valid file of parameters.
This function computes and save a number of sampling_size with 
the parameters enclosed in the file .json.

# Arguments
- `sampling_size::Int64`: Number of samples.
- `json_file_name::String` Path of json file with all parameters. 
...
"""
function montecarlo_sampling(
    sampling_size=10000,
    json_file_name="data/parameters_model.json"
)
    parameters = load_parameters_to_df(json_file_name)
    x0, df = get_solution_path!(parameters)
    #
    # 
    df_par = DataFrame()
    df_mc = DataFrame()
    #
    idx_path_par = ones(Int64, size(parameters)[1])
    idx_path = ones(Int64, size(df)[1])
    #
    insertcols!(parameters, 31, :idx_path => idx_path_par)
    insertcols!(df, 13, :idx_path => idx_path)
    df_mc = [df_mc; df]
    df_par = [df_par; parameters]
    n = sampling_size
    p = Progress(n, 1, "Sampling")
    for idx in 2:sampling_size
        par = get_stochastic_perturbation(json_file_name)
        x0, df = get_solution_path!(par)
        idx_path_par = idx * ones(Int64, size(par)[1])
        idx_path = idx * ones(Int64, size(df)[1])
        insertcols!(par, 31, :idx_path => idx_path_par)
        insertcols!(df, 13, :idx_path => idx_path)
        df_par = [df_par; par]
        df_mc = [df_mc; df]
        next!(p)
    end
    # saving par time seires
    prefix_file_name = "df_par"
    #
    d = Dates.now()
    tag = "(" * Dates.format(d, "yyyy-mm-dd_HH:MM)")
    suffix_file_name = ".csv"
    csv_file_name = prefix_file_name * tag * suffix_file_name
    path_par = "./data/" * csv_file_name
    CSV.write(path_par, df_par)
    # 
    prefix_file_name = "df_mc"
    csv_file_name = prefix_file_name * suffix_file_name
    path_mc = "./data/" * csv_file_name
    CSV.write(path_mc, df_mc)
    return df_par, df_mc, path_par, path_mc
end