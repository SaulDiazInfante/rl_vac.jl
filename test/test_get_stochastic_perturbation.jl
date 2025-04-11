@testset "get_stochastic_perturbation tests" begin
    args = build_testing_parameters()
    inventory_par = args["inventory_parameters"]
    Random.seed!(1234)
    original_t_delivery = copy(inventory_par.t_delivery)
    original_delivery_size_k = copy(inventory_par.delivery_size_k)

    result = get_stochastic_perturbation!(args)

    @test isa(result, Vector{Tuple{Float64,Float64}})
    @test length(result) == length(original_t_delivery)
    perturbed_t_delivery = inventory_par.t_delivery
    perturbed_delivery_size_k = inventory_par.delivery_size_k

    for i in eachindex(original_t_delivery)
        if i > 1 && i < length(original_t_delivery)
            delta_t = original_t_delivery[i] - original_t_delivery[i-1]
            @test (
                0.0 <=
                perturbed_t_delivery[i] - perturbed_t_delivery[i-1]
                <=
                2 * delta_t
            )
        end
        @test (
            0.0 <=
            perturbed_delivery_size_k[i] <=
            2 * original_delivery_size_k[i]
        )
    end

    @test perturbed_t_delivery[1] == original_t_delivery[1]
    @test perturbed_t_delivery[end] == original_t_delivery[end]
    @test args["inventory_parameters"].t_delivery == perturbed_t_delivery
    @test(
        args["inventory_parameters"].delivery_size_k ==
        perturbed_delivery_size_k
    )
end
