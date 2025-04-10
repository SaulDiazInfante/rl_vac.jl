@testset "tag_file tests" begin
    # Test case 1: Basic functionality
    args = Dict(
        "path" => "/home/user/",
        "prefix_file_name" => "log_",
        "suffix_file_name" => ".txt"
    )
    result = tag_file(args)
    @test occursin(
        r"^/home/user/log_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.txt$",
        result
    )

    args = Dict(
        "path" => "./data/",
        "prefix_file_name" => "output_",
        "suffix_file_name" => ".csv"
    )
    result = tag_file(args)
    @test occursin(
        r"^./data/output_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.csv$",
        result
    )

    args = Dict(
        "path" => "/tmp/",
        "prefix_file_name" => "",
        "suffix_file_name" => ""
    )
    result = tag_file(args)
    @test occursin(
        r"^/tmp/\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)$",
        result
    )

    args = Dict(
        "path" => "/home/user/"
    )
    @test_throws KeyError tag_file(args)
end


@testset "tag_file tests" begin
    args = Dict(
        "path" => "/home/user/",
        "prefix_file_name" => "log_",
        "suffix_file_name" => ".txt"
    )
    result = tag_file(args)
    @test occursin(
        r"^/home/user/log_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.txt$",
        result
    )

    args = Dict(
        "path" => "./data/",
        "prefix_file_name" => "output_",
        "suffix_file_name" => ".csv"
    )
    result = tag_file(args)
    @test occursin(
        r"^./data/output_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.csv$",
        result
    )

    args = Dict(
        "path" => "/tmp/",
        "prefix_file_name" => "",
        "suffix_file_name" => ""
    )
    result = tag_file(args)
    @test occursin(
        r"^/tmp/\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)$",
        result
    )

    args = Dict(
        "path" => "/home/user/"
        # Missing "prefix_file_name" and "suffix_file_name"
    )
    @test_throws KeyError tag_file(args)

    args1 = Dict(
        "path" => "/var/log/",
        "prefix_file_name" => "error_",
        "suffix_file_name" => ".log"
    )
    args2 = Dict(
        "path" => "/ignored/",
        "prefix_file_name" => "ignored_",
        "suffix_file_name" => ".ignored"
    )
    result = tag_file(args1, args2)
    @test occursin(
        r"^/var/log/error_\(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}\)\.log$",
        result
    )
end
