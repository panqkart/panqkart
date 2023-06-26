--[[
	## StreetsMod 2.0 ##
	Submod: poles
	Optional: true
]]

minetest.register_node(":streets:bigpole", {
	description = "Pole Straight",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
				{ x = 0, y = -2, z = 0 }
			}
		}
	},
	streets_pole_connection = {
		[0] = { 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		[1] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0 },
		[2] = { 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		[3] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0 },
		["t"] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 }
	}
})

minetest.register_craft({
	output = "streets:bigpole 3",
	recipe = {
		{ "default:steel_ingot" },
		{ "default:steel_ingot" }
	}
})


minetest.register_node(":streets:bigpole_short", {
	description = "Pole Short",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.15, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		[1] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
		[2] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		[3] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 },
		["t"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_short 2",
	recipe = {
		{ "streets:bigpole" }
	}
})


minetest.register_node(":streets:bigpole_edge", {
	description = "Pole Edge",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.15, 0.15 },
			{ -0.15, -0.15, -0.15, 0.15, 0.15, -0.5 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 },
		[1] = { 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
		[2] = { 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0 },
		[3] = { 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0 },
		["t"] = { 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_edge 3",
	recipe = {
		{ "streets:bigpole", "streets:bigpole" },
		{ "streets:bigpole", "" }
	}
})

minetest.register_craft({
	output = "streets:bigpole_edge 3",
	recipe = {
		{ "streets:bigpole", "streets:bigpole" },
		{ "", "streets:bigpole" }
	}
})


minetest.register_node(":streets:bigpole_tjunction", {
	description = "Pole T-Junction",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.15, 0.15 },
			{ -0.15, -0.15, -0.5, 0.15, 0.15, 0.5 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
		[1] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1 },
		[2] = { 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
		[3] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1 },
		["t"] = { 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_tjunction",
	recipe = {
		{ "streets:bigpole_edge", "streets:bigpole_short" },
	}
})


minetest.register_node(":streets:bigpole_corner", {
	description = "Pole Corner",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.15, 0.15 },
			{ -0.15, -0.15, -0.15, 0.15, 0.15, -0.5 },
			{ -0.15, -0.15, -0.15, 0.5, 0.15, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 },
		[1] = { 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1 },
		[2] = { 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1 },
		[3] = { 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0 },
		["t"] = { 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_corner",
	recipe = {
		{ "streets:bigpole_edge" },
		{ "streets:bigpole_short" }
	}
})


minetest.register_node(":streets:bigpole_four_side_junction", {
	description = "Pole 4-Side-Junction",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
			{ -0.15, -0.15, -0.15, 0.15, 0.15, -0.5 },
			{ -0.15, -0.15, -0.15, 0.5, 0.15, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 },
		[1] = { 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1 },
		[2] = { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1 },
		[3] = { 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0 },
		["t"] = { 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_four_side_junction",
	recipe = {
		{ "streets:bigpole_short" },
		{ "streets:bigpole_corner" }
	}
})


minetest.register_node(":streets:bigpole_cross", {
	description = "Pole Cross",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
			{ -0.15, -0.15, -0.5, 0.15, 0.15, 0.5 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
		[1] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1 },
		[2] = { 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
		[3] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1 },
		["t"] = { 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_cross",
	recipe = {
		{ "", "streets:bigpole_short", "" },
		{ "streets:bigpole_short", "", "streets:bigpole_short" },
		{ "", "streets:bigpole_short", "" },
	}
})


minetest.register_node(":streets:bigpole_five_side_junction", {
	description = "Pole 5-Side-Junction",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
			{ -0.15, -0.15, -0.5, 0.15, 0.15, 0.5 },
			{ -0.15, -0.15, -0.15, 0.5, 0.15, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0 },
		[1] = { 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1 },
		[2] = { 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1 },
		[3] = { 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 },
		["t"] = { 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_five_side_junction",
	recipe = {
		{ "streets:bigpole_cross", "streets:bigpole_short" }
	}
})


minetest.register_node(":streets:bigpole_all_sides", {
	description = "Pole All Sides",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_pole.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 },
			{ -0.15, -0.15, -0.5, 0.15, 0.15, 0.5 },
			{ -0.5, -0.15, -0.15, 0.5, 0.15, 0.15 }
		}
	},
	on_place = minetest.rotate_node,
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
			}
		}
	},
	streets_pole_connection = {
		[0] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		[1] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		[2] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		[3] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		["t"] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		["b"] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
	}
})

minetest.register_craft({
	output = "streets:bigpole_all_sides",
	recipe = {
		{ "streets:bigpole_short", "streets:bigpole_cross", "streets:bigpole_short" }
	}
})
