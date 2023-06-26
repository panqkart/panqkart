--[[
	## StreetsMod 2.0 ##
	Submod: steelsupport
	Optional: true
]]

minetest.register_node(":streets:steel_support", {
	description = "Steel support",
	tiles = { "streets_support.png" },
	groups = { cracky = 1 },
	drawtype = "glasslike_framed",
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	collision_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
		},
	},
})

minetest.register_craft({
	output = "streets:steel_support 5",
	recipe = {
		{ "default:steel_ingot", "", "default:steel_ingot" },
		{ "", "default:steel_ingot", "" },
		{ "default:steel_ingot", "", "default:steel_ingot" }
	}
})
