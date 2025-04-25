function mock_function()
    @info "This is an info message"
    @warn "This is a warning"
    @error "This is an error"
end

@testset "log_to_file tests" begin
    temp_file = "test_log.txt"
    log_to_file(temp_file, mock_function)
    try
        log_contents = read(temp_file, String)
        @test occursin("┌ Info: This is an info message\n", log_contents)
    finally
        # Clean up the temporary file
        isfile(temp_file) && rm(temp_file)
    end
end