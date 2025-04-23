@testset "save_interval_solution Tests" begin
    args = build_testing_parameters()
    process_first_inventory_reorder_point!(args)
    sol = get_stage_solution!(args)

    df_result = save_interval_solution(sol)
    @test names(df_result) == string.(collect(fieldnames(structState)))
    @test df_result[1, :time] == 0.0
    @test df_result[1, :t_index_interval] == 1
    # Check if the file was created with the correct name
    file_name = "interval_solution_01.csv"
    @test isfile(file_name)
    # Check if the file contents match the DataFrame
    df_from_file = CSV.read(file_name, DataFrame)
    @test df_from_file == df_result
    # Clean up the generated file
    rm(file_name, force=true)
end
