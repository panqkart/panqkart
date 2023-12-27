local import_mod = ...

local modname = minetest.get_current_modname()
local MP = minetest.get_modpath(modname)

function import_mod.read_manifest()
	local infile = io.open(MP .. "/manifest.json", "r")
	local instr = infile:read("*a")
	infile:close()

	return minetest.parse_json(instr or "{}")
end
