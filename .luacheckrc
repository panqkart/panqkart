unused_args = false
allow_defined_top = true
max_line_length = false

globals = {
    "default", "minetest", "core", "core_game",
	"lib_mount", "vehicle_mash", "mobs", "formspec_ast", "player_api",

	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},
}

read_globals = {
	"DIR_DELIM",
	"dump",
	"vector",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "PcgRandom",
	"ItemStack",
	"Settings",
	"unpack",
	"random_messages",
	"car_shop",
	"rules",
	"hud_fs",
	"intllib",
	"dungeon_loot",
	"ngettext",
	"lucky_block",
	"invisibility",
	"tnt",
	"toolranks",
	"cmi",

	"IsPlayerNodeOwner",
	"HasOwner",
	"getLastOwner",
	"GetNodeOwnerName",
	"isprotect",
	"protector",
	"digiline",
	"modlib",
	"sfinv",
	"farming",
	"stairsplus",
	"creative",
}

-- Don't report on legacy definitions of globals.
files["mods/default/legacy.lua"].global = false

files["mods/lib_mount/init.lua"].ignore = { "eye_offset", "attach_at",
    "set_animation", "new_velo" }

-- These are unused functions/variables that might be used in the future.
files["mods/vehicle_mash/init.lua"].ignore = { "cars_def", "other_car_names", "mesecar_def", "mesecar_names",
	"boat_def", "boat_names" }

-- We don't wanna mess up Mobs REDO API.
files["mods/mobs_redo/api.lua"].ignore = { "" }
files["mods/mobs_animal/locale/po2tr.lua"].ignore = { "" }

-- Code below taken from https://github.com/luk3yx/minetest-formspec_ast/blob/master/.luacheckrc

-- This error is thrown for methods that don't use the implicit "self"
-- parameter.
ignore = {"212/self"}
