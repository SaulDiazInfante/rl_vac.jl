using Test
using JSON3
using rl_vac


Base.@kwdef struct Person
    name::String
    age::Int
    city::Union{String,Missing}
end

function create_temp_json(content::String)
    temp_file = "./tests" * tempname() * ".json"
    open(temp_file, "w") do io
        write(io, content)
    end
    return temp_file
end

@testset "json_to_struct Tests" begin
    # Test 1: Valid JSON with all fields
    json_content = """
        {
            "name": "Alice",
            "age": 30,
            "city": "New York"
        }
    """
    temp_file = create_temp_json(json_content)
    person = json_to_struct(Person, temp_file)
    @test person.name == "Alice"
    @test person.age == 30
    @test person.city == "New York"
    rm(temp_file)

    # Test 2: JSON with missing optional field
    json_content = """
    {
        "name": "Bob",
        "age": 25
    }
    """
    temp_file = create_temp_json(json_content)
    person = json_to_struct(Person, temp_file)
    @test person.name == "Bob"
    @test person.age == 25
    @test person.city === missing
    rm(temp_file)

    # Test 3: JSON with incorrect type
    json_content = """
    {
        "name": "Charlie",
        "age": "not_a_number",
        "city": "Los Angeles"
    }
    """
    temp_file = create_temp_json(json_content)
    @test_throws MethodError json_to_struct(Person, temp_file)
    rm(temp_file)

    # Test 4: JSON with extra fields
    json_content = """
    {
        "name": "Diana",
        "age": 40,
        "city": "Chicago",
        "extra_field": "extra_value"
    }
    """
    temp_file = create_temp_json(json_content)
    person = json_to_struct(Person, temp_file)
    @test person.name == "Diana"
    @test person.age == 40
    @test person.city == "Chicago"
    rm(temp_file)
end