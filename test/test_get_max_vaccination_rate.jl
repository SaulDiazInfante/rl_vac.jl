
@testset "get_max_vaccination_rate!" begin
    args = build_testing_parameters()
    vaccine_coverage = 0.003
    result = get_max_vaccination_rate!(vaccine_coverage, args)
    expected_rate = -log(1.0 - vaccine_coverage) / (80.0 - 0.0)
    @test result ≈ expected_rate
    @test args["model_parameters"].psi_v ≈ expected_rate

    args["state"].time = 4.0
    args["inventory_parameters"].t_delivery = [1.0, 3.0, 5.0]
    args["model_parameters"].psi_v = 0.0

    vaccine_coverage = 0.0
    result = get_max_vaccination_rate!(vaccine_coverage, args)
    @test result == 0.0
    @test args["model_parameters"].psi_v == 0.0


    vaccine_coverage = 1e-20

    result = get_max_vaccination_rate!(vaccine_coverage, args)
    @test result ≈ 0.0 atol = eps(Float64)
    @test args["model_parameters"].psi_v ≈ 0.0 atol = eps(Float64)
end