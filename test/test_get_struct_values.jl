if !isdefined(Main, :TestStruct)
    struct TestStruct
        a::Int
        b::String
        c::Float64
    end
end
@testset "get_struct_values tests" begin
    test_instance = TestStruct(42, "hello", 3.14)
    @test get_struct_values(test_instance) == [42, "hello", 3.14]
    struct EmptyStruct end
    empty_instance = EmptyStruct()
    @test get_struct_values(empty_instance) == []
    struct SingleFieldStruct
        x::Bool
    end
    single_field_instance = SingleFieldStruct(true)
    @test get_struct_values(single_field_instance) == [true]
end