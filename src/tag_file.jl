"""
    tag_file(str_args::Dict{String,String}...)::String

Generates a tagged file name based on the provided arguments and the current date and time.

# Arguments
- `str_args::Dict{String,String}...`: A variable number of dictionaries containing the following keys:
  - `"path"`: The base path for the file (as a string).
  - `"prefix_file_name"`: The prefix to be added to the file name (as a string).
  - `"suffix_file_name"`: The suffix to be added to the file name (as a string).

# Returns
- `String`: A concatenated string representing the tagged file name, which includes the path, prefix, a timestamp in the format `yyyy-mm-dd_HH:MM`, and the suffix.

# Example
"""

function tag_file(str_args::Dict{String,String}...)::String
    date = Dates.now()
    args = str_args[1]
    path = args["path"]
    prefix_file_name = args["prefix_file_name"]
    suffix_file_name = args["suffix_file_name"]
    time_stamp = "(" * Dates.format(date, "yyyy-mm-dd_HH:MM") * ")"
    tag = path * prefix_file_name * time_stamp * suffix_file_name
    return tag
end
