function register_pane(name, def)
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
		use_texture_alpha = true,
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
		use_texture_alpha = true,
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

local panes_list = {
	{ "white", "White", "ffffff" },     { "blue", "Blue", "0000FF" },
	{ "cyan", "Cyan", "00FFFF" },       { "green", "Green", "00FF00" },
	{ "magenta", "Magenta", "FF00FF" }, { "orange", "Orange", "FF6103" },
	{ "violet", "Purple", "800080" },   { "red", "Red", "FF0000" },
	{ "yellow", "Yellow", "FFFF00" },   { "black", "Darkened", "292421" }
}

for i in ipairs(panes_list) do
	local name = panes_list[i][1]
	local description = panes_list[i][2]
	local colour = panes_list[i][3]
	local tex = "abriglass_plainglass.png^[colorize:#"..colour..":122"

	register_pane("abriglass_pane_"..name, {
		description = description.." Glass Pane",
		textures = {tex, tex, tex},
		groups = {cracky = 3},
		use_texture_alpha = true,
		wield_image = tex,
		inventory_image = tex,
		sounds = default.node_sound_glass_defaults(),
		recipe = {
			{"default:glass", "default:glass", "default:glass",},
			{"default:glass", "default:glass", "default:glass",},
			{"","dye:"..name,"",},
		}
	})
end
