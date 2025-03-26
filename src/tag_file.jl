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
