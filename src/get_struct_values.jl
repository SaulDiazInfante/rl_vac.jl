"""
    get_struct_values(x)

Extracts the values of all fields from a given struct `x` and returns them as an array.

# Arguments
- `x`: An instance of a struct whose field values are to be extracted.

# Returns
- An array containing the values of all fields in the struct `x`, in the order they are defined.

# Example
"""
function get_struct_values(x)
    return [getfield(x, field) for field in fieldnames(typeof(x))]
end