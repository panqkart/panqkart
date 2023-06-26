--[[
	## StreetsMod 2.0 ##
	Submod: streetsapi
	Optional: false
	Category: Init
]]

local register_surface_nodes = function(friendlyname, name, tiles, groups, sounds, craft)
	minetest.register_node(":streets:" .. name, {
		description = friendlyname,
		tiles = tiles,
		groups = groups,
		sounds = sounds
	})
	minetest.register_craft(craft)
	if minetest.get_modpath("moreblocks") then
		stairsplus:register_all("streets", name, "streets:" .. name, {
			description = friendlyname,
			tiles = tiles,
			groups = groups,
			sounds = sounds
		})
	end
end

local register_sign_node = function(friendlyname, name, tiles, type, inventory_image, light_source)
	if type == "minetest" then
		tiles[5] = tiles[6] .. "^[colorize:#fff^[mask:(" .. tiles[6] .. "^" .. tiles[5] .. ")"
	elseif type == "normal" or type == "big" then
		tiles[2] = tiles[1] .. "^[colorize:#fff^[mask:(" .. tiles[1] .. "^" .. tiles[2] .. ")^[transformFX"
	end
	local def = {}
	def.description = friendlyname
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.tiles = tiles
	def.light_source = light_source
	def.groups = { cracky = 3, not_in_creative_inventory = 1, sign = 1 }
	def.drop = "streets:" .. name
	def.use_texture_alpha = "clip"
	if type == "minetest" then
		def.drawtype = "nodebox"
		def.inventory_image = tiles[6]
	elseif type == "normal" or type == "big" then
		def.drawtype = "mesh"
		def.inventory_image = tiles[1]
	end

	if inventory_image then
		def.inventory_image = inventory_image
	end

	local normal_def = table.copy(def)
	local center_def = table.copy(def)
	local polemount_def = table.copy(def)

	if type == "minetest" then
		normal_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
		}
		center_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
		}
		polemount_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, 0.8, 1 / 2, 1 / 2, 0.85 }
		}
	elseif type == "normal" then
		normal_def.mesh = "sign.obj"
		center_def.mesh = "sign_center.obj"
		polemount_def.mesh = "sign_polemount.obj"
	elseif type == "big" then
		normal_def.mesh = "sign_big.obj"
		center_def.mesh = "sign_center_big.obj"
		polemount_def.mesh = "sign_polemount_big.obj"
	end

	normal_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
	}
	center_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
	}
	polemount_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.8, 1 / 2, 1 / 2, 0.85 }
	}
	normal_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
	}
	center_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
	}
	polemount_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.8, 1 / 2, 1 / 2, 0.85 }
	}

	normal_def.after_place_node = function(pos)
		local behind_pos = { x = pos.x, y = pos.y, z = pos.z }
		local node = minetest.get_node(pos)
		local param2 = node.param2
		if param2 == 0 then
			behind_pos.z = behind_pos.z + 1
		elseif param2 == 1 then
			behind_pos.x = behind_pos.x + 1
		elseif param2 == 2 then
			behind_pos.z = behind_pos.z - 1
		elseif param2 == 3 then
			behind_pos.x = behind_pos.x - 1
		end
		local behind_node = minetest.get_node(behind_pos)
		local behind_nodes = {}
		behind_nodes["streets:roadwork_traffic_barrier"] = true
		behind_nodes["streets:roadwork_traffic_barrier_top"] = true
		behind_nodes["streets:concrete_wall"] = true
		behind_nodes["streets:concrete_wall_top"] = true
		behind_nodes["technic:concrete_post"] = true
		local behind_nodes_same_parity = {}
		behind_nodes_same_parity["streets:roadwork_traffic_barrier_straight"] = true
		behind_nodes_same_parity["streets:roadwork_traffic_barrier_top_straight"] = true
		behind_nodes_same_parity["streets:concrete_wall_straight"] = true
		behind_nodes_same_parity["streets:concrete_wall_top_straight"] = true
		local under_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
		local under_node = minetest.get_node(under_pos)
		local under_nodes = {}
		under_nodes["streets:roadwork_traffic_barrier"] = true
		under_nodes["streets:roadwork_traffic_barrier_straight"] = true
		under_nodes["streets:roadwork_traffic_barrier_top"] = true
		under_nodes["streets:roadwork_traffic_barrier_top_straight"] = true
		under_nodes["streets:concrete_wall"] = true
		under_nodes["streets:concrete_wall_straight"] = true
		under_nodes["streets:concrete_wall_top"] = true
		under_nodes["streets:concrete_wall_top_straight"] = true
		under_nodes["technic:concrete_post"] = true
		local upper_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
		local upper_node = minetest.get_node(upper_pos)
		if (minetest.registered_nodes[behind_node.name].groups.bigpole
				and minetest.registered_nodes[behind_node.name].streets_pole_connection[param2][behind_node.param2 + 1] ~= 1)
				or behind_nodes[behind_node.name] == true
				or (behind_nodes_same_parity[behind_node.name] and (behind_node.param2 + param2) % 2 == 0) then
			node.name = node.name .. "_polemount"
			minetest.set_node(pos, node)
		elseif (minetest.registered_nodes[under_node.name].groups.bigpole
				and minetest.registered_nodes[under_node.name].streets_pole_connection["t"][under_node.param2 + 1] == 1)
				or under_nodes[under_node.name] then
			node.name = node.name .. "_center"
			minetest.set_node(pos, node)
		elseif minetest.registered_nodes[upper_node.name].groups.bigpole then
			if minetest.registered_nodes[upper_node.name].streets_pole_connection["b"][upper_node.param2 + 1] == 1 then
				node.name = node.name .. "_center"
				minetest.set_node(pos, node)
			end
		end
	end

	minetest.register_node(":streets:" .. name, normal_def)
	minetest.register_node(":streets:" .. name .. "_center", center_def)
	minetest.register_node(":streets:" .. name .. "_polemount", polemount_def)

end

local register_marking_nodes = function(surface_friendlyname, surface_name, surface_tiles, surface_groups, surface_sounds, register_stairs, friendlyname, name, tex, r, basic)
	local rotation_friendly = ""
	if r == "r90" then
		rotation_friendly = " (R90)"
		tex = tex .. "^[transformR90"
	elseif r == "r180" then
		rotation_friendly = " (R180)"
		tex = tex .. "^[transformR180"
	elseif r == "r270" then
		rotation_friendly = " (R270)"
		tex = tex .. "^[transformR270"
	end

	if r ~= "" then
		r = "_" .. r
	end

	for color = 1, 2 do
		local colorname
		if color == 1 then
			colorname = "White"
		elseif color == 2 then
			colorname = "Yellow"
			tex = "" .. tex .. "^[colorize:#ecb100"
		end

		minetest.register_tool(":streets:tool_" .. name:gsub("{color}", colorname:lower()) .. r, {
			description = "Marking Tool: " .. friendlyname .. rotation_friendly .. " " .. colorname,
			groups = { not_in_creative_inventory = 1 },
			inventory_image = tex,
			wield_image = tex,
			on_place = function(itemstack, placer, pointed_thing)
				local player_name = placer:get_player_name()
				local pos = {} -- luacheck: no unused
				if pointed_thing["type"] == "node" then
					pos = pointed_thing.under
					pos.y = pos.y + 1
				else
					return itemstack
				end
				if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
					minetest.record_protection_violation(pos, name)
					return
				end
				if minetest.get_node(pos).name == "air" then
					minetest.set_node(pos, {
						name = "streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r,
						param2 = minetest.dir_to_facedir(placer:get_look_dir())
					})
				else
					return itemstack
				end
				local node = minetest.get_node(pos)
				local lower_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
				local lower_node = minetest.get_node(lower_pos)
				if lower_node and
						minetest.registered_nodes[lower_node.name] and
						minetest.registered_nodes[lower_node.name].groups and
						minetest.registered_nodes[lower_node.name].groups.asphalt and
						streets.surfaces.surfacetypes[lower_node.name] then
					local lower_node_basename = streets.surfaces.surfacetypes[lower_node.name].name
					lower_node.name = "streets:mark_" .. (node.name:sub(14)) .. "_on_" .. lower_node_basename
					lower_node.param2 = node.param2
					minetest.set_node(lower_pos, lower_node)
					minetest.remove_node(pos)
				elseif lower_node and
						minetest.registered_nodes[lower_node.name] and
						minetest.registered_nodes[lower_node.name].groups and
						minetest.registered_nodes[lower_node.name].groups.asphalt and
						minetest.registered_nodes[lower_node.name:gsub("asphalt", ("mark_" .. node.name:sub(14)) .. "_on_asphalt")] then
					lower_node.name = lower_node.name:gsub("asphalt", ("mark_" .. node.name:sub(14)) .. "_on_asphalt")
					minetest.set_node(lower_pos, lower_node)
					minetest.remove_node(pos)
				end
				itemstack:add_wear(65535 / 75)
				return itemstack
			end,
		})

		minetest.register_node(":streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r, {
			description = "Marking Overlay: " .. friendlyname .. rotation_friendly .. " " .. colorname,
			tiles = { tex, "streets_transparent.png" },
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			groups = { snappy = 3, attached_node = 1, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1 },
			sunlight_propagates = true,
			walkable = false,
			inventory_image = tex,
			wield_image = tex,
			use_texture_alpha = "clip",
			node_box = {
				type = "fixed",
				fixed = { -0.5, -0.5, -0.5, 0.5, -0.499, 0.5 }
			},
			selection_box = {
				type = "fixed",
				fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, -1 / 2 + 1 / 16, 1 / 2 }
			},
			drop = "",
		})

		local tiles = {}
		tiles[1] = surface_tiles[1]
		tiles[2] = surface_tiles[2] or surface_tiles[1] --If less than 6 textures are used, this'll "expand" them to 6
		tiles[3] = surface_tiles[3] or surface_tiles[1]
		tiles[4] = surface_tiles[4] or surface_tiles[1]
		tiles[5] = surface_tiles[5] or surface_tiles[1]
		tiles[6] = surface_tiles[6] or surface_tiles[1]
		tiles[1] = tiles[1] .. "^(" .. tex .. ")"
		tiles[5] = tiles[5] .. "^(" .. tex .. ")^[transformR180"
		tiles[6] = tiles[6] .. "^(" .. tex .. ")"
		local groups = streets.copytable(surface_groups)
		groups.not_in_creative_inventory = 1
		minetest.register_node(":streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name, {
			description = surface_friendlyname .. " with Marking: " .. friendlyname .. rotation_friendly .. " " .. colorname,
			groups = groups,
			sounds = surface_sounds,
			tiles = tiles,
			paramtype2 = "facedir",
			drop = "",
			use_texture_alpha = "clip",
			after_destruct = function(pos, oldnode)
				local newnode = oldnode
				newnode.name = oldnode.name:gsub("mark_(.-)_on_", "")
				minetest.set_node(pos, newnode)
			end,
		})
		minetest.register_craft({
			output = "streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
			type = "shapeless",
			recipe = { "streets:" .. surface_name, "streets:mark_" .. name:gsub("{color}", colorname:lower()) }
		})
		if register_stairs and ( not streets.only_basic_stairsplus or basic ) and (minetest.get_modpath("moreblocks") or minetest.get_modpath("stairsplus")) then
			local stairs_def = {
				description = surface_friendlyname .. " with Marking: " .. friendlyname .. rotation_friendly .. " " .. colorname,
				tiles = tiles,
				groups = surface_groups,
				sounds = surface_sounds,
				drop = {
					max_items = 1, -- Maximum number of items to drop.
					items = {
						-- Choose max_items randomly from this list.
						{
							items = { "" }, -- Choose one item randomly from this list.
							rarity = 1, -- Probability of getting is 1 / rarity.
						},
					},
				},
				after_destruct = function(pos, oldnode)
					local newnode = oldnode
					newnode.name = oldnode.name:gsub("mark_(.-)_on_", "")
					minetest.set_node(pos, newnode)
				end,
			}

			stairsplus:register_stair("streets",
				"mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				"streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				stairs_def)
			stairsplus:register_slab("streets",
				"mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				"streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				stairs_def)
			stairsplus:register_slope("streets",
				"mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				"streets:mark_" .. name:gsub("{color}", colorname:lower()) .. r .. "_on_" .. surface_name,
				stairs_def)
		end
	end
end

if streets.surfaces.surfacetypes then
	for _, v in pairs(streets.surfaces.surfacetypes) do
		register_surface_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.craft)
		if streets.labels.labeltypes then
			for _, w in pairs(streets.labels.labeltypes) do
				register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "", w.basic)
				if not streets.only_basic_stairsplus and w.rotation then
					if w.rotation.r90 then
						register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r90", w.basic)
					end
					if w.rotation.r180 then
						register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r180", w.basic)
					end
					if w.rotation.r270 then
						register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r270", w.basic)
					end
				elseif streets.only_basic_stairsplus and w.basic_rotation then
					if w.basic_rotation.r90 then
					register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r90", w.basic)
					end
					if w.basic_rotation.r180 then
						register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r180", w.basic)
					end
					if w.basic_rotation.r270 then
						register_marking_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.register_stairs, w.friendlyname, w.name, w.tex, "r270", w.basic)
					end
				end
			end
		end
	end
end

if streets.signs.signtypes then
	for _, v in pairs(streets.signs.signtypes) do
		register_sign_node(v.friendlyname, v.name, v.tiles, v.type, v.inventory_image, v.light_source)
	end
end
