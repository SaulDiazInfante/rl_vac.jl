
@testset "get_max_vaccination_rate!" begin
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)

    args["state"].time = 0.0
    vaccine_coverage = get_vaccine_stock_coverage(args)
    result = get_max_vaccination_rate!(vaccine_coverage, args)
    expected_rate = -log(1.0 - vaccine_coverage) / (80.0 - 0.0)
    @test result ≈ expected_rate

    args["state"].time = 79.4
    vaccine_coverage = get_vaccine_stock_coverage(args)
    result = get_max_vaccination_rate!(vaccine_coverage, args)
    expected_rate = -log(1.0 - vaccine_coverage) / (80.0 - 79.4)
    @test result ≈ expected_rate
    @test args["model_parameters"].psi_v ≈ expected_rate


    args["model_parameters"].psi_v =
    vaccine_coverage = 0.0
    result = get_max_vaccination_rate!(vaccine_coverage, args)
    @test result == 0.0
    @test args["model_parameters"].psi_v == 0.0


    vaccine_coverage = 1e-20

    result = get_max_vaccination_rate!(vaccine_coverage, args)
    @test result ≈ 0.0 atol = eps(Float64)
    @test args["model_parameters"].psi_v ≈ 0.0 atol = eps(Float64)

    args["state"].time = 365.0
    vaccine_coverage = get_vaccine_stock_coverage(args)
    result = get_max_vaccination_rate!(vaccine_coverage, args)
end

