unused_args = false
allow_defined_top = true
max_line_length = 999

globals = {
    "default", "minetest", "core", "core_game",
	"lib_mount", "vehicle_mash", "mobs", "formspec_ast",
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

	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},
}

-- Don't report on legacy definitions of globals.
files["mods/default/legacy.lua"].global = false
