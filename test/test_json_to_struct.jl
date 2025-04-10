Base.@kwdef struct TestStruct
    a::Union{Missing,Int}
    b::Union{Missing,String}
    c::Union{Missing,Float64}
end


function create_temp_json(content::String)
    relative_path = @__DIR__
    file_path = relative_path * tempname() * ".json"
    open(file_path, "w") do f
        write(f, content)
    end
    return file_path
end

@testset "json_to_struct tests" begin
    json_content = """
    {
        "a": 42,
        "b": "hello",
        "c": 3.14
    }
    """
    file_path = create_temp_json(json_content)
    result = json_to_struct(TestStruct, file_path)
    @test result == TestStruct(42, "hello", 3.14)

    json_content = """
    {
        "a": 10,
        "b": "world"
    }
    """
    file_path = create_temp_json(json_content)
    result = json_to_struct(TestStruct, file_path)
    @test result == TestStruct(10, "world", missing)


    json_content = """
    {
        "a": "not_an_int",
        "b": "test",
        "c": 1.23
    }
    """
    file_path = create_temp_json(json_content)
    @test_throws MethodError json_to_struct(TestStruct, file_path)


    json_content = """
    {
        "a": 7,
        "b": "extra",
        "c": 2.71,
        "extra_field": "ignored"
    }
    """
    file_path = create_temp_json(json_content)
    result = json_to_struct(TestStruct, file_path)
    @test result == TestStruct(7, "extra", 2.71)

    json_content = "{}"
    file_path = create_temp_json(json_content)
    result = json_to_struct(TestStruct, file_path)
    @test result == TestStruct(missing, missing, missing)
end