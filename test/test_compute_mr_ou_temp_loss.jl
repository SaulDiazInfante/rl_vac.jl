@testset "Basic Functionality Test" begin
    theta_T = 0.5
    mu_T = 20.0
    sigma_T = 2.0
    kappa = 0.1
    inventory_level = 100.0
    t0 = 0.0
    T_t_0 = 20.0
    h_coarse = 1.0
    n = 10
    n_omega = 5
    seed = 123
    debug_flag = false

    result = compute_mr_ou_temp_loss(
        theta_T=theta_T,
        mu_T=mu_T,
        sigma_T=sigma_T,
        kappa=kappa,
        inventory_level=inventory_level,
        t0=t0,
        T_t_0=T_t_0,
        h_coarse=h_coarse,
        n=n,
        n_omega=n_omega,
        seed=seed,
        debug_flag=debug_flag
    )

    @test typeof(result) == Dict{Symbol,Float64}
    @test :temp_j in keys(result)
    @test :lambda_j in keys(result)
    @test :loss_j in keys(result)
end

# Test 2: Debug mode returns DataFrame
@testset "Debug Mode Test" begin
    theta_T = 0.5
    mu_T = 20.0
    sigma_T = 2.0
    kappa = 0.1
    inventory_level = 100.0
    t0 = 0.0
    T_t_0 = 20.0
    h_coarse = 1.0
    n = 10
    n_omega = 5
    seed = 123
    debug_flag = true

    result = compute_mr_ou_temp_loss(
        theta_T=theta_T,
        mu_T=mu_T,
        sigma_T=sigma_T,
        kappa=kappa,
        inventory_level=inventory_level,
        t0=t0,
        T_t_0=T_t_0,
        h_coarse=h_coarse,
        n=n,
        n_omega=n_omega,
        seed=seed,
        debug_flag=debug_flag
    )

    @test typeof(result) == DataFrames.DataFrame
    @test all(
        x -> x in names(result),
        ["Step", "Time", "Temperature", "lambda", "Loss"]
    )
end

# Test 3: Edge case with zero volatility
@testset "Zero Volatility Test" begin
    theta_T = 0.5
    mu_T = 20.0
    sigma_T = 0.0
    kappa = 0.1
    inventory_level = 100.0
    t0 = 0.0
    T_t_0 = 20.0
    h_coarse = 1.0
    n = 10
    n_omega = 5
    seed = 123
    debug_flag = false

    result = compute_mr_ou_temp_loss(
        theta_T=theta_T,
        mu_T=mu_T,
        sigma_T=sigma_T,
        kappa=kappa,
        inventory_level=inventory_level,
        t0=t0,
        T_t_0=T_t_0,
        h_coarse=h_coarse,
        n=n,
        n_omega=n_omega,
        seed=seed,
        debug_flag=debug_flag
    )

    @test result[:temp_j] == mu_T
    @test result[:lambda_j] == 0.0
    @test result[:loss_j] == 0.0
end

# Test 4: Edge case with zero mean reversion rate
@testset "Zero Mean Reversion Rate Test" begin
    theta_T = 0.0
    mu_T = 20.0
    sigma_T = 2.0
    kappa = 0.1
    inventory_level = 100.0
    t0 = 0.0
    T_t_0 = 20.0
    h_coarse = 1.0
    n = 10
    n_omega = 5
    seed = 123
    debug_flag = false

    result = compute_mr_ou_temp_loss(
        theta_T=theta_T,
        mu_T=mu_T,
        sigma_T=sigma_T,
        kappa=kappa,
        inventory_level=inventory_level,
        t0=t0,
        T_t_0=T_t_0,
        h_coarse=h_coarse,
        n=n,
        n_omega=n_omega,
        seed=seed,
        debug_flag=debug_flag
    )

    @test result[:temp_j] != mu_T
end