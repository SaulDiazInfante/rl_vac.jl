using Test
using Dates
using rl_vac

# Test for the `tag_file` function
@testset "tag_file tests" begin
    # Test case 1: Basic functionality
    args = Dict(
        "path" => "/home/user/",
        "prefix_file_name" => "log_",
        "suffix_file_name" => ".txt"
    )
    result = tag_file(args)
    @test occursin(r"^/home/user/log_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.txt$", result)

    # Test case 2: Different path and file names
    args = Dict(
        "path" => "./data/",
        "prefix_file_name" => "output_",
        "suffix_file_name" => ".csv"
    )
    result = tag_file(args)
    @test occursin(r"^./data/output_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.csv$", result)

    # Test case 3: Empty prefix and suffix
    args = Dict(
        "path" => "/tmp/",
        "prefix_file_name" => "",
        "suffix_file_name" => ""
    )
    result = tag_file(args)
    @test occursin(r"^/tmp/\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)$", result)

    # Test case 4: Invalid input (missing keys)
    args = Dict(
        "path" => "/home/user/"
        # Missing "prefix_file_name" and "suffix_file_name"
    )
    @test_throws KeyError tag_file(args)
end