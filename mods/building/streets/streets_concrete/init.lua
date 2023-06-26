--[[
	## StreetsMod 2.0 ##
	Submod: Concrete
	Optional: true
]]

if minetest.get_modpath("concrete") then
	minetest.register_alias("streets:concrete", "technic:concrete")
else
	minetest.register_alias("technic:concrete", "streets:concrete")

	minetest.register_node("streets:concrete", {
		description = "Concrete",
		tiles = { streets.concrete_texture },
		groups = { cracky = 2, stone = 3 },
		sounds = default.node_sound_stone_defaults()
	})

	minetest.register_craft({
		output = "streets:concrete 5",
		recipe = {
			{ "default:steel_ingot", "default:stone", "default:steel_ingot" },
			{ "default:stone", "default:steel_ingot", "default:stone" },
			{ "default:steel_ingot", "default:stone", "default:steel_ingot" },
		}
	})

	if minetest.get_modpath("moreblocks") or minetest.get_modpath("stairsplus") then
		stairsplus:register_all("streets", "concrete", "streets:concrete", {
			description = "Concrete",
			tiles = { streets.concrete_texture },
			groups = { cracky = 2, stone = 3 },
			sounds = default.node_sound_stone_defaults()
		})
	end
end

minetest.register_node("streets:concrete_wall", {
	description = "Concrete Wall",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { streets.concrete_texture },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { { -0.35, -0.5, -0.35, 0.35, -0.4, 0.35 }, { -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 } },
		connect_front = { { -0.35, -0.5, -0.5, 0.35, -0.4, 0.35 }, { -0.15, -0.5, -0.5, 0.15, 0.5, 0.15 } }, -- z-
		connect_back = { { -0.35, -0.5, -0.35, 0.35, -0.4, 0.5 }, { -0.15, -0.5, -0.15, 0.15, 0.5, 0.5 } }, -- z+
		connect_left = { { -0.5, -0.5, -0.35, 0.35, -0.4, 0.35 }, { -0.5, -0.5, -0.15, 0.15, 0.5, 0.15 } }, -- x-
		connect_right = { { -0.35, -0.5, -0.35, 0.5, -0.4, 0.35 }, { -0.15, -0.5, -0.15, 0.5, 0.5, 0.15 } }, -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:concrete" },
	sound = default.node_sound_stone_defaults()
})


minetest.register_craft({
	output = "streets:concrete_wall 5",
	recipe = {
		{ "", "streets:concrete", "" },
		{ "", "streets:concrete", "" },
		{ "streets:concrete", "streets:concrete", "streets:concrete" },
	}
})

minetest.register_node("streets:concrete_wall_straight", {
	description = "Concrete Wall (Top)",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { streets.concrete_texture },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, wall = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.35, 0.5, -0.4, 0.35 },
			{ -0.5, -0.5, -0.15, 0.5, 0.5, 0.15 },
		},
	},
	connect_sides = { "left", "right" },
	sound = default.node_sound_stone_defaults()
})


minetest.register_craft({
	output = "streets:concrete_wall_straight 2",
	recipe = {
		{ "streets:concrete_wall", "streets:concrete_wall"},
	}
})


minetest.register_node("streets:concrete_wall_top", {
	description = "Concrete Wall",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { streets.concrete_texture },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
		connect_front = { -0.15, -0.5, -0.5, 0.15, 0.5, 0.15 }, -- z-
		connect_back = { -0.15, -0.5, -0.15, 0.15, 0.5, 0.5 }, -- z+
		connect_left = { -0.5, -0.5, -0.15, 0.15, 0.5, 0.15 }, -- x-
		connect_right = { -0.15, -0.5, -0.15, 0.5, 0.5, 0.15 }, -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:concrete" },
	sound = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "streets:concrete_wall_top 2",
	recipe = {
		{ "streets:concrete_wall" },
		{ "streets:concrete_wall"},
	}
})

minetest.register_node("streets:concrete_wall_top_straight", {
	description = "Concrete Wall (Straight Top)",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { streets.concrete_texture },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, wall = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.15, 0.5, 0.5, 0.15 },
		},
	},
	connect_sides = { "left", "right" },
	sound = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "streets:concrete_wall_top_straight 2",
	recipe = {
		{ "streets:concrete_wall_straight" },
		{ "streets:concrete_wall_straight"},
	}
})