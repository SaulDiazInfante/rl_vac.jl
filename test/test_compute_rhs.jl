# Simulate one trajectory of Ornstein–Uhlenbeck process 
using Random, DataFrames, Plots, rl_vac


json_file_name = "data/parameters_model.json"
parameters = load_parameters(json_file_name)
# x0, df = get_solution_path!(parameters)
N_grid_size = parameters.N_grid_size[1];
solution = zeros(Float64, N_grid_size, 17);
#unpack initial condition
S_0 = parameters.S_0[1]
E_0 = parameters.E_0[1]
I_S_0 = parameters.I_S_0[1]
I_A_0 = parameters.I_A_0[1]
R_0 = parameters.R_0[1]
D_0 = parameters.D_0[1]
V_0 = parameters.V_0[1]
X_vac_0 = 0.0
X_0_mayer = parameters.X_0_mayer[1]
k_0 = parameters.k_stock[1] / parameters.N[1]
operational_levels = parameters.operational_stock_levels
# #    "psi_v": 0.00123969,
CL0 = sum([S_0, E_0, I_S_0, I_A_0, R_0, D_0, V_0])
header_str = [
    "t", "S", "E",
    "I_S", "I_A", "R",
    "D", "V", "CL",
    "X_vac", "X_0_mayer", "K_stock",
    "T", "loss", "action",
    "opt_policy", "t_interval_idx"
]

x_0_vector = [
    0.0, S_0, E_0,
    I_S_0, I_A_0, R_0,
    D_0, V_0, CL0,
    X_vac_0, X_0_mayer, k_0,
    -70.0, 0.0, 0.0,
    1.0, 1
]
hat_N_n_0 = sum(x_0_vector[2:8]) - D_0
x_0 = DataFrame(
    Dict(
        zip(
            header_str,
            x_0_vector
        )
    )
)
t = 0.0
opt_policy = parameters.operational_stock_levels[end]
a_t = 0.25

rhs_evaluation!(
    t,
    x_0,
    opt_policy,
    a_t,
    parameters
)

