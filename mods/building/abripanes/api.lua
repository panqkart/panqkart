function abripanes.register_pane(name, def)
	for i = 1, 15 do
		minetest.register_alias("xpanes:" .. name .. "_" .. i, "xpanes:" .. name .. "_flat")
	end

	local flatgroups = table.copy(def.groups)
	flatgroups.pane = 1
	minetest.register_node(":xpanes:" .. name .. "_flat", {
		description = def.description,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		use_texture_alpha = "blend",
		light_source = 4,
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = flatgroups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connect_sides = { "left", "right" },
	})

	local groups = table.copy(def.groups)
	groups.pane = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":xpanes:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		use_texture_alpha = "blend",
		light_source = 4,
		description = def.description,
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = groups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		node_box = {
			type = "connected",
			fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
			connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
			connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
			connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
			connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connects_to = {"group:pane", "group:stone", "group:glass", "group:wood", "group:tree"},
	})

	minetest.register_craft({
		output = "xpanes:" .. name .. "_flat 16",
		recipe = def.recipe
	})
end