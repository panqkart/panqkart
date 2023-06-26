allow_defined_top = true
unused_args = false
max_line_length = false

globals = {
    "minetest", "default", "abriglass"
}

read_globals = {
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy", "getn"}},

    "DIR_DELIM",
}
