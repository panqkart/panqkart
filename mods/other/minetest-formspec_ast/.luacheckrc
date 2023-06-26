max_line_length = 80

globals = {
    'formspec_ast',
    'minetest',
}

read_globals = {
    string = {fields = {'split', 'trim'}},
    table = {fields = {'copy'}}
}

-- The elements.lua file is auto-generated and has a hideously long line which
-- luacheck complains about.
files["elements.lua"].ignore = {""}

-- Because formspec_ast supports running outside of MT, some string and table
-- functions are added in init.lua (unless running in MT).
files['init.lua'].globals = read_globals

-- This error is thrown for methods that don't use the implicit "self"
-- parameter.
ignore = {"212/self"}
