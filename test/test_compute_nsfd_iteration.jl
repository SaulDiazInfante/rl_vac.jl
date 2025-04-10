@testset "compute_nsfd_iteration!" begin
    args = build_testing_parameters()
    result = compute_nsfd_iteration!(args)

    # Validate results
    @test length(result) == 18
    @test isapprox(sum(result[2:8]), 1.0; atol=1e-12)
    @test args["state"].time == result[1]
    @test args["state"].S == result[2]
    @test args["state"].E == result[3]
    @test args["state"].I_S == result[4]
    @test args["state"].I_A == result[5]
    @test args["state"].R == result[6]
    @test args["state"].D == result[7]
    @test args["state"].V == result[8]
end