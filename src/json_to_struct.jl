"""
    json_to_struct(::Type{T}, file_path::String) where {T}

Converts a JSON file into an instance of the specified struct type `T`.

# Arguments
- `::Type{T}`: The type of the struct to which the JSON data will be converted.
- `file_path::String`: The path to the JSON file to be read.

# Returns
- An instance of the struct type `T` populated with the data from the JSON file.

# Details
- The function reads the JSON file specified by `file_path` and parses it into a dictionary.
- It then iterates over the fields of the struct type `T`, converting the corresponding values from the JSON data to the appropriate types.
- If a field is missing in the JSON data, it will be set to `missing`.

# Example
"""

function json_to_struct(::Type{T}, file_path::String) where {T}
    json_str = read(file_path, String)
    raw_data = JSON3.read(json_str, Dict{String,Any})

    field_syms = fieldnames(T)
    field_types = T.types

    converted = Dict{Symbol,Any}()

    for (name, typ) in zip(field_syms, field_types)
        val = get(raw_data, String(name), missing)
        converted[name] = convert(typ, val)
    end

    return T(; converted...)
end