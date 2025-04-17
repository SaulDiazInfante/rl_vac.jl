args = build_testing_parameters()

@testset "build_interval_stencil!" begin
    numeric_solver_parameters = args["numeric_solver_parameters"]

    stencil = build_interval_stencil!(args)
    updated_numeric_solver_parameters = args["numeric_solver_parameters"]
    expected_stage_stencil = LinRange(
        numeric_solver_parameters.current_stage_interval[1],
        numeric_solver_parameters.current_stage_interval[2],
        numeric_solver_parameters.N_grid_size
    )
    expected_h = expected_stage_stencil[2] - expected_stage_stencil[1]
    expected_refinement_step_size = (
        expected_h / numeric_solver_parameters.N_refinement_per_step
    )
    @test updated_numeric_solver_parameters.step_size_h ≈ expected_h
    @test updated_numeric_solver_parameters.refinement_step_size_h ≈ (
        expected_refinement_step_size
    )
    @test stencil ≈ expected_stage_stencil
end
