using rl_vac
using Test
using DataFrames, CSV
using Coverage
import CoverageTools, LibGit2
p = load_parameters(
    "../data/parameters_model.json"
)
p_sto = get_stochastic_perturbation();
t = 90.0;
a_t = 0.25;
k = 0.0015;
S = p.S_0[1];
E = p.E_0[1];
I_S = p.I_S_0[1];
I_A = p.I_A_0[1];
R = p.R_0[1];
D = p.D_0[1];
V = p.V_0[1];
X_vac = p.X_vac_interval[1]
X_0_mayer = p.X_0_mayer[1]
K_stock = p.k_stock[1]
k_0 = p.k_stock[1] / p.N[1]
CL = sum([S, E, I_S, I_A, R, D, V])
opt_policy = 1.0
N_grid_size = p.N_grid_size[1];
time_horizon_1 = p.t_delivery[2]
t_interval_1 = LinRange(0, time_horizon_1, N_grid_size)
operational_levels = p.operational_stock_levels
solution = zeros(Float64, N_grid_size, 13);

header_str = [
    "t", "S", "E", "I_S",
    "I_A", "R", "D", "V", "CL",
    "X_vac", "X_0_mayer", "K_stock",
    "action", "opt_policy"
]
x_0_vector = [
    0.0, S, E,
    I_S, I_A, R,
    D, V, CL,
    X_vac, X_0_mayer, K_stock,
    0.0, 1.0
]
hat_N_n_0 = sum(x_0_vector[2:8]) - D
opt_policy = operational_levels[end]
t_delivery_1 = p.t_delivery[2]
x_0 = DataFrame(
    Dict(
        zip(
            header_str,
            x_0_vector
        )
    )
)

x_df = DataFrame(
    Dict(
        zip(header_str, x_0_vector)
    )
)
x_new =
    rhs_evaluation!(
        t, x_df, opt_policy, a_t, k, p
    )
x_new_df = DataFrame(
    Dict(
        zip(header_str, x_new)
    )
)
x_c =
    get_vaccine_stock_coverage(k_0, p)
t = 80.0
k = 2

a_t = get_vaccine_action!(x_c, t_delivery_1, p)

x = get_interval_solution!(
    t_interval_1,
    x_0,
    opt_policy,
    a_t,
    k_0,
    p
);
time = x[:, 1]
#

# TODO: GetSolutionPath documentation
#@code_coverage begin
@testset "rl_vac.jl" begin
    # Test for load_parameters.jl
    @test(
        load_parameters(
            "../data/parameters_model.json"
        ).N_grid_size[1] == 500
    )

    # Test for get_stencil_projection.jl
    @test get_stencil_projection(t, p) == 2

    # Test for rhs_evaluation.jl
    @test sum(x_new[2:8]) == 1.0

    # Test for get_stochastic_perturbation.jl
    @test p.t_delivery[2] != p_sto.t_delivery[2]

    # Test for computing_cost.jl
    @test(
        compute_cost(x_df, p) ==
        999999.9621877202
    )
    @test(
        get_vaccine_stock_coverage(
            k, p
        ) >= 0.0
    )
    @test(
        get_vaccine_action!(
            x_c, t, p
        ) >= 0.0
    )
    sol = get_interval_solution!(
        t_interval_1,
        x_0,
        opt_policy,
        a_t,
        k_0,
        p
    )
    cl_sol = sum(sol[end, 2:8])
    @test(
        isapprox(cl_sol, 1.0, rtol=1e-2, atol=1e-3)
    )
    names_str = ["time", "S", "E",
        "I_S", "I_A", "R",
        "D", "V", "CL",
        "X_vac", "K_stock", "action"
    ]
    df = save_interval_solution(x;
        header_str=names_str,
        file_name="solution_interval.csv"
    )
    @test(
        issetequal(names(df), names_str)
    )

    sol_path = get_solution_path!(p)
    @test(
        isapprox(sol_path[1].CL[1], 1.0, rtol=1e-2, atol=1e-3)
    )

    json_file = "../data/parameters_model.json"
    df_par, df_mc, path_par, path_mc =
        montecarlo_sampling(10, json_file)

    @test(
        typeof(path_mc) == String
    )
    @test(
        typeof(df_par) == DataFrame
    )
    path = "./data/df_mc.csv"
    trajectories = CSV.read(path, DataFrame)
    idx_0 = (trajectories.idx_path .== 1)
    query = trajectories[idx_0, :]
    line_time = query.time
    interpolated_trajectory_1 =
        get_interpolated_solution(
            query,
            line_time
        )

    is_cl = sum(
        interpolated_trajectory_1[end, [:S, :E, :I_A, :I_S, :R, :V, :D]]
    )
    #=
    @test(
        isapprox(is_cl, 1.0, rtol=1e-2, atol=1e-3)
    )
    =#
    test_data = get_simulation_statistics()
    cond = test_data[1] .>= test_data[2]
    @test(
        nrow(cond) == sum(cond.S)
    )

end
##

@testset "Coverage" begin
    # set up base system ENV vars for testing
    withenv(
        "DISABLE_AMEND_COVERAGE_FROM_SRC" => nothing,
        "COVERALLS_TOKEN" => "token_name_1",
        "COVERALLS_URL" => nothing,
        "CODECOV_URL" => nothing,
        "CODECOV_URL_PATH" => nothing,
        "CODECOV_TOKEN" => nothing,
        "CODECOV_NAME" => nothing,
        "CODECOV_FLAGS" => nothing,
        "TRAVIS" => nothing,
        "TRAVIS_BRANCH" => nothing,
        "TRAVIS_COMMIT" => nothing,
        "TRAVIS_PULL_REQUEST" => nothing,
        "TRAVIS_BUILD_NUMBER" => nothing,
        "TRAVIS_JOB_ID" => nothing,
        "TRAVIS_JOB_NUMBER" => nothing,
        "TRAVIS_REPO_SLUG" => nothing,
        "APPVEYOR" => nothing,
        "APPVEYOR_PULL_REQUEST_NUMBER" => nothing,
        "APPVEYOR_ACCOUNT_NAME" => nothing,
        "APPVEYOR_PROJECT_SLUG" => nothing,
        "APPVEYOR_BUILD_VERSION" => nothing,
        "APPVEYOR_REPO_BRANCH" => nothing,
        "APPVEYOR_REPO_COMMIT" => nothing,
        "APPVEYOR_REPO_NAME" => nothing,
        "APPVEYOR_BUILD_NUMBER" => nothing,
        "APPVEYOR_BUILD_ID" => nothing,
        "APPVEYOR_JOB_ID" => nothing,
        "GITHUB_ACTION" => nothing,
        "GITHUB_EVENT_PATH" => nothing,
        "GITHUB_HEAD_REF" => nothing,
        "GITHUB_REF" => nothing,
        "GITHUB_REPOSITORY" => nothing,
        "GITHUB_RUN_ID" => nothing,
        "GITHUB_SHA" => nothing,
        "service_job_id" => nothing,
        "JENKINS" => nothing,
        "BUILD_ID" => nothing,
        "CI_PULL_REQUEST" => nothing,
        "GIT_BRANCH" => nothing
    ) do

        @testset "codecovio.jl" begin
            # these methods are only used for testing the token generation for local repos
            # and CI whilst not breaking the current API
            construct_uri_string_local(dir=pwd(); kwargs...) = Coverage.Codecov.construct_uri_string(
                Coverage.Codecov.add_local_to_kwargs(dir; kwargs...))

            construct_uri_string_ci(; kwargs...) = Coverage.Codecov.construct_uri_string(
                Coverage.Codecov.add_ci_to_kwargs(; kwargs...))

            # empty file coverage for testing
            fcs = FileCoverage[]

            # test local submission process (but only if we are in a git repo)
            _dotgit = joinpath(dirname(@__DIR__), ".git")
            if isdir(_dotgit) || isfile(_dotgit)
                LibGit2.with(LibGit2.GitRepoExt(pwd())) do repo
                    # default values
                    codecov_url = construct_uri_string_local()
                    @test occursin("codecov.io", codecov_url)
                    @test occursin("commit=", codecov_url)
                    @test occursin("branch=", codecov_url)
                    @test !occursin("service", codecov_url)

                    # env var url override
                    withenv("CODECOV_URL" => "https://enterprise-codecov-1.com") do

                        codecov_url = construct_uri_string_local()
                        @test occursin("enterprise-codecov-1.com", codecov_url)
                        @test occursin("commit=", codecov_url)
                        @test occursin("branch=", codecov_url)
                        @test !occursin("service", codecov_url)

                        # function argument url override
                        codecov_url = construct_uri_string_local(codecov_url="https://enterprise-codecov-2.com")
                        @test occursin("enterprise-codecov-2.com", codecov_url)
                        @test occursin("commit=", codecov_url)
                        @test occursin("branch=", codecov_url)
                        @test !occursin("service", codecov_url)
                        @test !occursin("name", codecov_url)
                        @test !occursin("flags", codecov_url)

                        # env var token
                        withenv("CODECOV_TOKEN" => "token_name_1",
                            "CODECOV_NAME" => "cv_name",
                            "CODECOV_FLAGS" => "cv_flags") do

                            codecov_url = construct_uri_string_local()
                            @test occursin("enterprise-codecov-1.com", codecov_url)
                            @test occursin("token=token_name_1", codecov_url)
                            @test occursin("name=cv_name", codecov_url)
                            @test occursin("flags=cv_flags", codecov_url)
                            @test !occursin("service", codecov_url)

                            # function argument token url override
                            codecov_url = construct_uri_string_local(token="token_name_2")
                            @test occursin("enterprise-codecov-1.com", codecov_url)
                            @test occursin("token=token_name_2", codecov_url)
                            @test !occursin("service", codecov_url)
                        end
                    end
                end
            else
                @warn "skipping local repo tests for Codecov, since not a git repo"
            end
        end
    end
    #Coverage.report()
end

