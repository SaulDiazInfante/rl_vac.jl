"""
compute_mr_ou_temp_loss(;
    theta_T::Float64,
    mu_T::Float64,
    sigma_T::Float64,
    kappa::Float64,
    inventory_level::Float64,
    t0::Float64,
    h_coarse::Float64,
    n::Int32,
    n_omega::Int32,
    seed=123,
    debug_flag=false
)
Simulates an Ornstein–Uhlenbeck process 
using the Euler–Maruyama method with n_omega 
random variables per winner increment.
Returns the dictionary Loss_n_k
with the last temperature of represented by a 
Ornstein Uhlenbeck process, the regarding exponential
waste and the corresponding loss
= Dict(
        :temp_j => Temp_i,
        :lambda_j => lambda_i,
        :loss_j => Loss_i
    )

# Arguments
- `theta_T`: Mean reversion rate.
- `mu_T`: Long-term mean.
- `sigma_T`: Volatility coefficient.
- `t0`: Initial time.
- `N`: Number of major time subdivisions.
- `n`: Number of sub‑refined steps per major subdivision.
- `n_omega`: Number or normal random variables to generate the Winner increment

# Returns
`Loss``
A `DataFrame` with columns:
- `Step`: Overall simulation step index.
- `MajorStep`: Major step index (from 1 to N+1).
- `SubStep`: Sub‑step index within each major step (from 1 to n).
- `Time`: Simulation time at each step.
- `T`: The simulated process value at each time.
"""
function compute_mr_ou_temp_loss(;
    theta_T::Float64,
    mu_T::Float64,
    sigma_T::Float64,
    kappa::Float64,
    inventory_level::Float64,
    t0::Float64,
    T_t_0::Float64,
    h_coarse::Float64,
    n::Int64,
    n_omega::Int64,
    seed=123,
    debug_flag=false
)
    # Calculate major and sub‑refined time steps.
    #
    h_fine = h_coarse / n
    h_res = h_fine / n_omega

    #
    # Preallocate vectors for simulation.
    times = zeros(n + 1)
    T = zeros(n + 1)
    lambda = zeros(n + 1)
    Loss = zeros(n + 1)
    dim = n * n_omega
    if debug_flag
        rng = Xoshiro(seed)
        dW = sqrt(h_res) * randn(rng, Float64, dim)
    else
        dW = sqrt(h_res) * randn(dim)
    end
    # Initialize the first entry.
    times[1] = t0
    Temp_i = T_t_0
    lambda_i = 0.0
    T[1] = T_t_0    # starting with the mean temperature
    lambda[1] = 0.0
    Loss[1] = 0.0
    Loss_i = 0.0

    # Perform Euler–Maruyama simulation with refined BM
    for i in 1:n
        times[i+1] = times[i] + h_fine
        W_inc = sum(dW[n_omega*(i-1)+1:n_omega*i])
        # TODO: implement here the Steklov method
        # Temp_i = T[i] + theta_T * (mu_T - T[i]) * h_fine + sigma_T * W_inc
        Temp_i = exp(-theta_T * h_fine) * (T[i] - mu_T) + mu_T + sigma_T * W_inc
        T[i+1] = Temp_i
        lambda_i = kappa * maximum([0.0, (Temp_i - mu_T)])
        lambda[i+1] = lambda_i
        Loss_i = inventory_level * (1.0 - exp(-lambda_i * h_fine))
        Loss[i+1] = Loss_i
    end
    Loss_n_k = Dict(
        :temp_j => Temp_i,
        :lambda_j => lambda_i,
        :loss_j => Loss_i
    )
    df = DataFrame(
        Step=0:n,
        Time=times,
        Temperature=T,
        lambda=lambda,
        Loss=Loss
    )
    if debug_flag
        return df
    else
        return Loss_n_k
    end
end