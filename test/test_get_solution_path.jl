@testset "get_solution_path! tests" begin
      args = build_testing_parameters()
      solution_path = get_solution_path!(args)
      @test typeof(solution_path) == Matrix{Real}
      @test size(solution_path, 1) == N_GRIDE_SIZE * (length(
            args["inventory_parameters"].t_delivery
      ) - 1
      )
      @test haskey(args, "state")
      @test haskey(args, "initial_condition")
end
