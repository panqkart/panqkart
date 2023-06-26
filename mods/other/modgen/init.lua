local MP = minetest.get_modpath("modgen")
local storage = minetest.get_mod_storage()

local VERSION = 4

-- mod namespace
modgen = {
	pos1 = {},
	pos2 = {},
	MOD_PATH = MP,
	CHUNK_LENGTH = 80,

	-- current version
	version = VERSION,

	-- autosave feature
	autosave = storage:get_int("autosave") == 1,

	-- mod storage
	storage = storage,

	-- export path for the generated mod
	export_path = minetest.get_worldpath() .. "/modgen_mod_export",

	-- manifest of already existing import-mod if available
	manifest = {
		-- stats
		size = 0,
		chunks = 0,

		-- exported name to nodeid mapping
		node_mapping = {},
		-- next nodeid

		next_id = 0,
		-- current export/import version
		version = VERSION
	},

	-- enables saving mapblocks in-place
	enable_inplace_save = false
}

-- create export directories
minetest.mkdir(modgen.export_path)
minetest.mkdir(modgen.export_path .. "/map")

-- secure/insecure environment
local global_env = _G

local ie = minetest.request_insecure_environment and minetest.request_insecure_environment()
if ie then
	print("[modgen] using insecure environment")
	-- register insecure environment
	global_env = ie

	-- enable in-place saving
	modgen.enable_inplace_save = true
end

-- pass on global env (secure/insecure)
loadfile(MP.."/functions.lua")(global_env)
loadfile(MP.."/manifest.lua")(global_env)

dofile(MP.."/hud.lua")
dofile(MP.."/debug.lua")
dofile(MP.."/encode.lua")
dofile(MP.."/chunk.lua")
dofile(MP.."/markers.lua")
dofile(MP.."/register.lua")
dofile(MP.."/serialize.lua")
dofile(MP.."/iterator_next.lua")
dofile(MP.."/export.lua")
dofile(MP.."/autosave.lua")
dofile(MP.."/commands/stats.lua")
dofile(MP.."/commands/export.lua")
dofile(MP.."/commands/export_here.lua")
dofile(MP.."/commands/autosave.lua")
dofile(MP.."/commands/pos.lua")

-- try to read existing manifest in worldpath
modgen.read_manifest(modgen.export_path .. "/manifest.json")

if minetest.get_modpath("mtt") then
	dofile(MP.."/iterator_next.spec.lua")
end