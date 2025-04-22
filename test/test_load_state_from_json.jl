@testset "load_state_from_json tests" begin
    test_json_file = "./test_data/test_parameters_model.json"
    test_data = Dict("param1" => 1, "param2" => 2, "param3" => 3)
    mkpath(dirname(test_json_file))
    open(test_json_file, "w") do io
        JSON3.write(io, test_data)
    end

    df = load_state_from_json(test_json_file)
    @test isa(df, DataFrame)
    @test nrow(df) == 1
    @test ncol(df) == length(test_data)
    @test all(names(df) .== keys(test_data))

    @test_throws SystemError load_state_from_json("./non_existent_file.json")
    invalid_json_file = "./test_data/invalid.json"
end