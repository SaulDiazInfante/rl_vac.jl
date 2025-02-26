# Simulate one trajectory of Ornstein–Uhlenbeck process 
using rl_vac, GLMakie

p_dict = Dict(
    :theta_T => 0.3,
    :mu_T => -70.0,
    :sigma_T => 1.25,
    :kappa => 0.1,
    :inventory_level => 0.22687367881531104,
    :t0 => 0.0,
    :T_t_0 => -70.0,
    :h_coarse => 0.36,
    :n => Int32(100),
    :n_omega => Int32(10),
    :seed => 42,
    :debug_flag => false
)
loss_k = compute_mr_ou_temp_loss(; p_dict...)
#
p_dict[:debug_flag] = true # For debugging 
#
df_ou_loss = compute_mr_ou_temp_loss(; p_dict...)



fig = Figure(resolution=(800, 600))
plot_T = Axis(fig[1, 1], title="Subplot 1")
lines!(plot_T,
    df_ou_loss.Time,
    df_ou_loss.Temperature
)

plot_lambda = Axis(fig[2, 1], title="Subplot 2")

lines!(df_ou_loss.Time,
    df_ou_loss.lambda
)

plot_loss = Axis(fig[3, 1], title="Subplot 3")
lines!(
    df_ou_loss.Time,
    df_ou_loss.Loss
)
fig