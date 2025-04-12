using Test
using .rl_vac

@testset "rhs_evaluation! tests" begin

    args = build_testing_parameters()
    result = rhs_evaluation!(args)
    @test length(result) == length(fieldnames(structState))
    @test isapprox(sum(result[2:8]), 1.0; atol=1e-12)
    @test args["state"].time == result[1]
    @test args["state"].S == result[2]
    @test args["state"].E == result[3]
    @test args["state"].I_S == result[4]
    @test args["state"].I_A == result[5]
    @test args["state"].R == result[6]
    @test args["state"].D == result[7]
    @test args["state"].V == result[8]
    @test args["state"].Conservative_Law == result[9]
    @test args["state"].X_vac == result[10]
    @test args["state"].previous_stage_cumulative_vaccination ==
          args["initial_condition"].previous_stage_cumulative_vaccination
    @test args["state"].X_0_mayer == result[12]
    @test args["state"].K_stock_t == result[13]
    @test args["state"].T == result[14]
    @test args["state"].stock_loss == result[15]
    @test args["state"].action == result[16]
    @test args["state"].opt_policy == result[17]
    @test args["state"].t_index_interval == result[18]
    @test args["state"].time > 0.0
end