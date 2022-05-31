--[[
	## StreetsMod 2.0 ##
	Submod: signs
	Optional: true
]]

--These register the sections in the workshop that these will be placed into
streets.signs.sections = {
	{ name = "warn", friendlyname = "MT Warning" },
	{ name = "reg", friendlyname = "MT Regulatory" },
	{ name = "info", friendlyname = "MT Information" },
	{ name = "usreg", friendlyname = "US Regulatory" },
	{ name = "uswarn", friendlyname = "US Warning" },
	{ name = "usinfo", friendlyname = "US Information" },
	{ name = "usom", friendlyname = "US Object Markers" },
	{ name = "usttc", friendlyname = "US TTC" },
	{ name = "euprio", friendlyname = "EU Priority" },
	{ name = "euwarn", friendlyname = "EU Warning" },
	{ name = "euprohib", friendlyname = "EU Prohibitory" },
	{ name = "eumandat", friendlyname = "EU Mandatory" },
	{ name = "euinfo", friendlyname = "EU Info" },
	{ name = "euother", friendlyname = "EU Other" }
}

minetest.register_alias("streets:sign_blank", "default:sign_wall_steel")

streets.register_road_sign({
	name = "sign_curve_chevron_right",
	friendlyname = "Curve Chevron Sign (Right)",
	tiles = {
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_curve_sign.png"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { yellow = 3, black = 3 }
})

streets.register_road_sign({
	name = "sign_curve_chevron_left",
	friendlyname = "Curve Chevron Sign (Left)",
	tiles = {
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_sign_back.png",
		"streets_curve_sign.png^[transformFX"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { yellow = 3, black = 3 }
})

streets.register_road_sign({
	name = "sign_warning",
	friendlyname = "Warning Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_warning.png"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { black = 2 }
})

streets.register_road_sign({
	name = "sign_water",
	friendlyname = "Water Warning Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_water.png"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { green = 1, blue = 3, black = 1 }
})

streets.register_road_sign({
	name = "sign_lava",
	friendlyname = "Lava Warning Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_lava.png"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { green = 1, red = 3 }
})

streets.register_road_sign({
	name = "sign_construction",
	friendlyname = "Construction Warning Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_construction.png"
	},
	type = "minetest",
	section = "warn",
	dye_needed = { green = 1, blue = 1, brown = 1 }
})

streets.register_road_sign({
	name = "sign_grass",
	friendlyname = "No Walking on Grass Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_grass.png"
	},
	type = "minetest",
	section = "reg",
	dye_needed = { green = 3, red = 2 }
})

streets.register_road_sign({
	name = "sign_mine",
	friendlyname = "Mine Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_mine.png"
	},
	type = "minetest",
	section = "info",
	dye_needed = { blue = 2, yellow = 1 }
})

streets.register_road_sign({
	name = "sign_shop",
	friendlyname = "Shop Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_shop.png"
	},
	type = "minetest",
	section = "info",
	dye_needed = { blue = 1, red = 1, yellow = 1 }
})

streets.register_road_sign({
	name = "sign_work_shop",
	friendlyname = "Workshop Sign",
	tiles = {
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png^[colorize:#D20000FF",
		"streets_sign_back.png",
		"streets_square_sign_empty.png^streets_sign_workshop.png"
	},
	type = "minetest",
	section = "info",
	dye_needed = { red = 1, yellow = 2, blue = 1 }
})

--US Signs
dofile(streets.conf.modpath .. "/streets_signs/us/usreg.lua")
dofile(streets.conf.modpath .. "/streets_signs/us/uswarn.lua")
dofile(streets.conf.modpath .. "/streets_signs/us/usinfo.lua")
dofile(streets.conf.modpath .. "/streets_signs/us/usom.lua")
dofile(streets.conf.modpath .. "/streets_signs/us/usttc.lua")

--EU Signs
dofile(streets.conf.modpath .. "/streets_signs/eu/euwarn.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euother.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euprio.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/eumandat.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euprohib.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euinfo.lua")
