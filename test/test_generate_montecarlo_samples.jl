using Test
using rl_vac
using DataFrames, CSV, JSON
using Debugger, ProgressMeter
@testset "generate_montecarlo_samples tests" begin
    generate_montecarlo_samples(3)
    data_dir = joinpath(@__DIR__, "../data")
    data_path = mkpath(data_dir)
    @testset "Output file creation" begin
        expected_files = [
            joinpath(data_path, "df_mc.csv"),
            joinpath(data_path, "df_initial_condition.csv"),
            joinpath(data_path, "df_inventory_parameters.csv")
        ]

        for file in expected_files
            @test isfile(file)
        end
    end

    @testset "Output file content" begin

        for file in expected_files
            df = CSV.read(file, DataFrame)
            @test nrow(df) > 0
        end
    end
    @testset "Sampling size validation" begin
        df_mc = CSV.read(expected_files[1], DataFrame)
        unique_paths = unique(df_mc.idx_path)
        @test length(unique_paths) == 3
    end
end
