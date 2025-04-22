args = build_testing_parameters()
state = args["state"]
@testset "save_state_to_json tests" begin
    @testset "Basic functionality" begin
        filename = "test_output.json"
        df = save_state_to_json(state, filename)
        @test size(df) == (1, 18)
        @test df[1, :time] == 0.0
        @test df[1, :opt_policy] == 0.0
        @test df[1, :K_stock_t] == 0.0
        @test isfile(filename)
        rm(filename, force=true)
    end
end