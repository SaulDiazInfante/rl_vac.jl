args = build_testing_parameters()
state = args["state"]
@testset "save_state_to_csv tests" begin
    @testset "Basic functionality" begin
        filename = "test_output.csv"
        df = save_state_to_csv(state, filename)
        @test size(df) == (1, 18)
        @test df[1, :time] == 0.0
        @test df[1, :opt_policy] == 0.0
        @test df[1, :K_stock_t] == 0.0
        @test isfile(filename)
        rm(filename, force=true)
    end
end