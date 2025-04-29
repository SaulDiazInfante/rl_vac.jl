using Test
using rl_vac
inventory_parameters_path = joinpath(
    @__DIR__,
    "../data/inventory_parameters.json"
)
inventory_par = json_to_struct(
    structInventoryParameters, inventory_parameters_path
)


# Test cases for `get_stencil_projection`
@testset "get_stencil_projection tests" begin
    par = inventory_par
    t = 3.5
    @test get_stencil_projection(t, par) == 1

    t = 90.0
    @test get_stencil_projection(t, par) == 2
    t = -1.0
    @test_throws ArgumentError get_stencil_projection(t, par)
    t = 79.5
    @test get_stencil_projection(t, par) == 1
    t = 80.0
    @test get_stencil_projection(t, par) == 2
    t = 365.0
    @test get_stencil_projection(t, par) == 6
end