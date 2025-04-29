@testset "get_solution_path! tests" begin
      args = build_testing_parameters()
      inventory_parameters = args["inventory_parameters"]
      NUM_STAGES = length(inventory_parameters.t_delivery) - 1
      solution_path = get_solution_path!(args)
      @test typeof(solution_path) == Matrix{Real}
      @test size(solution_path, 1) == N_GRIDE_SIZE * NUM_STAGES
      @test haskey(args, "state")
      @test haskey(args, "initial_condition")
end