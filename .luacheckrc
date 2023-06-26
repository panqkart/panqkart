unused_args = false
allow_defined_top = true
max_line_length = false

globals = {
	"default", "minetest", "core", "core_game", "modgen",
	"lib_mount", "vehicle_mash", "mobs", "formspec_ast", "player_api",

	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn", "contains"}}
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
	"worldedit",
	"mtt",
	"inventory_plus",
	"unified_inventory"
}

-- Don't report on legacy definitions of globals.
files["mods/mtg/default/legacy.lua"].global = false

files["mods/pk/lib_mount/init.lua"].ignore = { "eye_offset", "attach_at",
    "set_animation", "new_velo" }

-- These are unused functions/variables that might be used in the future.
files["mods/pk/vehicle_mash/init.lua"].ignore = { "cars_def", "mesecar_def", "mesecar_names",
	"boat_def", "boat_names" }

-- This error is thrown for methods that don't use the implicit "self"
-- parameter.
ignore = {"212/self"}

-- Ignore WorldEdit warnings. Those should be fixed upstream.
files["mods/building/Minetest-WorldEdit/*/*.lua"].ignore = { "" }
