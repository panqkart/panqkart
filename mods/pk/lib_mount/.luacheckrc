unused_args = false
allow_defined_top = true
max_line_length = 999

globals = {
    "lib_mount", "player_api",
}

read_globals = {
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy", "getn"}},

    "minetest", "mobs", "vector",
}

files["init.lua"].ignore = { "eye_offset", "attach_at",
    "set_animation", "new_velo" }
