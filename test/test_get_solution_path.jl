@testset "get_solution_path! tests" begin
      args = build_testing_parameters()
      solution_path = get_solution_path!(args)
      @test typeof(solution_path) == Vector{Matrix{Real}}
      @test length(solution_path) ==
            length(args["inventory_parameters"].t_delivery) - 1

      for stage_solution in solution_path
            @test size(stage_solution, 2) == 18
      end
      @test haskey(args, "state")
      @test haskey(args, "initial_condition")
end
