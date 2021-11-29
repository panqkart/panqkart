--[[
	## StreetsMod 2.0 ##
	Submod: accessories
	Optional: true
]]

minetest.register_node(":streets:delineator", {
	description = "Delineator",
	tiles = { "streets_delineator_top.png", "streets_delineator_top.png", "streets_delineator_left.png", "streets_delineator_right.png", "streets_delineator_back.png", "streets_delineator_front.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { snappy = 2 },
	light_source = 2,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.125, -0.5, -0.0625, 0.125, 0.4375, 0.0625 }, -- Body
			{ 0, 0.4375, -0.0625, 0.125, 0.5, 0.0625 }, -- Top
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.125, -0.5, -0.0625, 0.125, 0.5, 0.0625 }, -- Body
		}
	}
})

minetest.register_craft({
	output = "streets:delineator 10",
	recipe = {
		{ "dye:orange", "default:steel_ingot", "dye:orange" },
		{ "dye:white", "default:steel_ingot", "dye:black" }
	}
})

minetest.register_node("streets:fence_chainlink", {
	description = "Chainlink Fence",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { "streets_fence_chainlink.png" },
	sunlight_propagates = true,
	groups = { snappy = 1, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { { -1 / 32, -0.5, -1 / 32, 1 / 32, 0.5, 1 / 32 } },
		connect_front = { { 0, -0.5, -0.5, 0, 0.5, 0 } }, -- z-
		connect_back = { { 0, -0.5, 0, 0, 0.5, 0.5 } }, -- z+
		connect_left = { { -0.5, -0.5, 0, 0, 0.5, 0 } }, -- x-
		connect_right = { { 0, -0.5, 0, 0.5, 0.5, 0 } }, -- x+
	},
	selection_box = {
		type = "connected",
		fixed = { { -1 / 16, -0.5, -1 / 16, 1 / 16, 0.5, 1 / 16 } },
		connect_front = { { 0, -0.5, -0.5, 0, 0.5, 0 } }, -- z-
		connect_back = { { 0, -0.5, 0, 0, 0.5, 0.5 } }, -- z+
		connect_left = { { -0.5, -0.5, 0, 0, 0.5, 0 } }, -- x-
		connect_right = { { 0, -0.5, 0, 0.5, 0.5, 0 } }, -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:concrete" },
	sound = default.node_sound_stone_defaults()
})

local function toggleDoor(pos, node, player, action)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
		minetest.record_protection_violation(pos, name)
		return
	end
	local newnode = node
	if action == "close" then
		newnode.name = node.name:gsub("open", "closed")
	elseif action == "open" then
		newnode.name = node.name:gsub("closed", "open")
	end
	minetest.swap_node(pos, newnode)
	local upper_pos = streets.copytable(pos)
	upper_pos.y = upper_pos.y + 1
	local upper_node = minetest.get_node(upper_pos)
	if (upper_node.name == "streets:fence_chainlink_door_closed" and action == "open")
			or (upper_node.name == "streets:fence_chainlink_door_open" and action == "close") then
		toggleDoor(upper_pos, upper_node, player, action)
	end
	local under_pos = streets.copytable(pos)
	under_pos.y = under_pos.y - 1
	local under_node = minetest.get_node(under_pos)
	if (under_node.name == "streets:fence_chainlink_door_closed" and action == "open")
			or (under_node.name == "streets:fence_chainlink_door_open" and action == "close") then
		toggleDoor(under_pos, under_node, player, action)
	end
end

minetest.register_node("streets:fence_chainlink_door_open", {
	description = "Chainlink Fence Door (Locked)",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_fence_chainlink_door.png" },
	sunlight_propagates = true,
	groups = { snappy = 1, wall = 1, not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -16 / 32, -0.5, -1 / 32, -14 / 32, 0.5, 1 / 32 },
			{ 14 / 32, -0.5, -1 / 32, 16 / 32, 0.5, 1 / 32 },
			{ -15 / 32, -0.5, 0, -15 / 32, 0.5, 0.5 },
			{ 15 / 32, -0.5, 0, 15 / 32, 0.5, 0.5 }
		},
	},
	sound = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		toggleDoor(pos, node, player, "close")
	end,
	drop = "streets:fence_chainlink_door_closed",
})

minetest.register_node("streets:fence_chainlink_door_closed", {
	description = "Chainlink Fence Door (Locked)",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_fence_chainlink_door.png" },
	sunlight_propagates = true,
	groups = { snappy = 1, wall = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -16 / 32, -0.5, -1 / 32, -14 / 32, 0.5, 1 / 32 },
			{ 14 / 32, -0.5, -1 / 32, 16 / 32, 0.5, 1 / 32 },
			{ -15 / 32, -0.5, 0, 15 / 32, 0.5, 0 }
		},
	},
	sound = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		toggleDoor(pos, node, player, "open")
	end,
})



minetest.register_craft({
	output = "streets:fence_chainlink 33",
	recipe = {
		{ "", "dye:dark_green", "" },
		{ "default:steel_ingot", "default:stick", "default:steel_ingot" },
		{ "default:steel_ingot", "default:stick", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:fence_chainlink_door_closed",
	recipe = {
		{ "streets:fence_chainlink", "streets:fence_chainlink", "" },
		{ "streets:fence_chainlink", "streets:fence_chainlink", "" },
		{ "streets:fence_chainlink", "streets:fence_chainlink", "" }
	}
})

minetest.register_node("streets:guardrail", {
	description = "Guardrail",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { "streets_guardrail.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, wall = 1 },
	node_box = {
		type = "connected",
		fixed = {
			{ -0.1, -0.5, -0.1, 0.1, 0.5, 0.1 },
		},
		connect_front = {
			{ 0, -0.1875, -0.5, 0, 0.4375, 0 },
			{ -0.0625, 0.1875, -0.5, 0.0625, 0.3125, 0 },
			{ -0.0625, -0.0625, -0.5, 0.0625, 0.0625, 0 },
		}, -- z-
		connect_back = {
			{ 0, -0.1875, 0, 0, 0.4375, 0.5 },
			{ -0.0625, 0.1875, 0, 0.0625, 0.3125, 0.5 },
			{ -0.0625, -0.0625, 0, 0.0625, 0.0625, 0.5 },
		}, -- z+
		connect_left = {
			{ -0.5, -0.1875, 0, 0, 0.4375, 0 },
			{ -0.5, 0.1875, -0.0625, 0, 0.3125, 0.0625 },
			{ -0.5, -0.0625, -0.0625, 0, 0.0625, 0.0625 },
		}, -- x-
		connect_right = {
			{ 0, -0.1875, 0, 0.5, 0.4375, 0 },
			{ 0, 0.1875, -0.0625, 0.5, 0.3125, 0.0625 },
			{ 0, -0.0625, -0.0625, 0.5, 0.0625, 0.0625 },
		}, -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:concrete" },
	sound = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "streets:guardrail 12",
	recipe = {
		{ "streets:bigpole", "default:steel_ingot", "streets:bigpole" },
		{ "streets:bigpole", "default:steel_ingot", "streets:bigpole" }
	}
})