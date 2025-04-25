
"""
    log_to_file(file_path::String, func::Function)

Logs the output of a given function `func` to a specified file.

# Arguments
- `file_path::String`: The path to the file where the log will be written.
- `func::Function`: The function whose logging output will be captured and written to the file.

# Details
This function creates a logger that writes to the specified file with a logging level of `Debug`. 
It temporarily sets this logger as the active logger while executing the provided function `func`.

# Example
"""
function log_to_file(file_path::String, func::Function)
    open(file_path, "w") do io
        logger = SimpleLogger(io, Logging.Debug)  # or Info, Warn, etc.
        with_logger(logger) do
            func()
        end
    end
end