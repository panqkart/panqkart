--[[
	## StreetsMod 2.0 ##
	Submod: rrxing
	Optional: true
]]

streets.rrxing_sound_handles = {}

local function play_bell(pos)
	local pos_hash = minetest.hash_node_position(pos)
	if not streets.rrxing_sound_handles[pos_hash] then
		streets.rrxing_sound_handles[pos_hash] = minetest.sound_play("streets_rrxing_bell",
			{ pos = pos, gain = 0.66, loop = true, max_hear_distance = 20, })
	end
end

local function stop_bell(pos)
	local pos_hash = minetest.hash_node_position(pos)
	local sound_handle = streets.rrxing_sound_handles[pos_hash]
	if sound_handle then
		minetest.sound_stop(sound_handle)
		streets.rrxing_sound_handles[pos_hash] = nil
	end
end

local function left_light_direction(pos, param2)
	if param2 == 0 then
		pos.x = pos.x - 1
	elseif param2 == 1 then
		pos.z = pos.z + 1
	elseif param2 == 2 then
		pos.x = pos.x + 1
	elseif param2 == 3 then
		pos.z = pos.z - 1
	end
end

local function right_light_direction(pos, param2)
	if param2 == 0 then
		pos.x = pos.x + 2
	elseif param2 == 1 then
		pos.z = pos.z - 2
	elseif param2 == 2 then
		pos.x = pos.x - 2
	elseif param2 == 3 then
		pos.z = pos.z + 2
	end
end

local function lights_on(pos)
	local node = minetest.get_node(pos)
	local param2 = node.param2
	minetest.swap_node(pos, { name = "streets:rrxing_middle_center_on", param2 = node.param2 })
	left_light_direction(pos, param2)
	minetest.swap_node(pos, { name = "streets:rrxing_middle_left_on", param2 = node.param2 })
	right_light_direction(pos, param2)
	minetest.swap_node(pos, { name = "streets:rrxing_middle_right_on", param2 = node.param2 })
end

local function lights_off(pos)
	local node = minetest.get_node(pos)
	local param2 = node.param2
	minetest.swap_node(pos, { name = "streets:rrxing_middle_center_off", param2 = node.param2 })
	left_light_direction(pos, param2)
	minetest.swap_node(pos, { name = "streets:rrxing_middle_left_off", param2 = node.param2 })
	right_light_direction(pos, param2)
	minetest.swap_node(pos, { name = "streets:rrxing_middle_right_off", param2 = node.param2 })
end

local function toggle_lights(pos)
	pos.y = pos.y + 2
	local node = minetest.get_node(pos)
	if node.name == "streets:rrxing_middle_center_off" then
		play_bell(pos)
		lights_on(pos)
	elseif (node.name == "streets:rrxing_middle_center_on") then
		stop_bell(pos)
		lights_off(pos)
	end
end

minetest.register_node("streets:rrxing_top", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_top_back.png",
		"streets_rrxing_top_back.png",
		"streets_rrxing_top_back.png",
		"streets_rrxing_top.png"
	},
	on_destruct = stop_bell,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 3, not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 0, 1 / 16 },
			{ -1 / 8, 0, -1 / 8, 1 / 8, 3 / 8, 1 / 8 },
			{ -1 / 4, 1 / 8, -1 / 4, 1 / 4, 1 / 4, 1 / 4 },
			{ -1 / 2, -1 / 2, -1 / 16, 1 / 2, 0, -1 / 16 },
			{ -1 / 8, -1 / 2, -1 / 16, 1 / 8, -1 / 4, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle_right_on", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_right_back.png",
		{ name = "streets_rrxing_middle_right_on.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } }
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { not_in_creative_inventory = 1 },
	light_source = 12,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 2, -1 / 2, -1 / 16, -1 / 4, 1 / 2, -1 / 16 },
			{ -1 / 2, -5 / 16, -1 / 16, -7 / 16, 1 / 16, 3 / 16 },
			{ -1 / 2, 1 / 32, -5 / 16, -15 / 32, 3 / 32, -1 / 16 },
			{ -15 / 32, -1 / 8, -3 / 16, -13 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle_right_off", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_right_back.png",
		"streets_rrxing_middle_right_off.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 2, -1 / 2, -1 / 16, -1 / 4, 1 / 2, -1 / 16 },
			{ -1 / 2, -5 / 16, -1 / 16, -7 / 16, 1 / 16, 3 / 16 },
			{ -1 / 2, 1 / 32, -5 / 16, -15 / 32, 3 / 32, -1 / 16 },
			{ -15 / 32, -1 / 8, -3 / 16, -13 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle_left_on", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_left_back.png",
		{ name = "streets_rrxing_middle_left_on.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } }
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 12,
	groups = { not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ 1 / 4, -1 / 2, -1 / 16, 1 / 2, 1 / 2, -1 / 16 },
			{ 7 / 16, -5 / 16, -1 / 16, 1 / 2, 1 / 16, 3 / 16 },
			{ 15 / 32, 1 / 32, -5 / 16, 1 / 2, 3 / 32, -1 / 16 },
			{ 13 / 32, -1 / 8, -3 / 16, 15 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle_left_off", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_left_back.png",
		"streets_rrxing_middle_left_off.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ 1 / 4, -1 / 2, -1 / 16, 1 / 2, 1 / 2, -1 / 16 },
			{ 7 / 16, -5 / 16, -1 / 16, 1 / 2, 1 / 16, 3 / 16 },
			{ 15 / 32, 1 / 32, -5 / 16, 1 / 2, 3 / 32, -1 / 16 },
			{ 13 / 32, -1 / 8, -3 / 16, 15 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle_center_on", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_center_back.png",
		"streets_rrxing_middle_center_back.png",
		"streets_rrxing_middle_center_back.png",
		{ name = "streets_rrxing_middle_center_on.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } }
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 12,
	groups = { not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -1 / 2, -1 / 2, -1 / 16, 1 / 2, 1 / 2, -1 / 16 },
			{ -1 / 2, -5 / 16, -1 / 16, -3 / 16, 1 / 16, 3 / 16 },
			{ 3 / 16, -5 / 16, -1 / 16, 1 / 2, 1 / 16, 3 / 16 },
			{ -3 / 16, -3 / 16, -1 / 16, 3 / 16, -1 / 16, 1 / 8 },
			{ -1 / 2, 1 / 32, -5 / 16, -7 / 32, 3 / 32, -1 / 16 },
			{ -7 / 32, -1 / 8, -3 / 16, -5 / 32, 1 / 32, -1 / 16 },
			{ 7 / 32, 1 / 32, -5 / 16, 1 / 2, 3 / 32, -1 / 16 },
			{ 5 / 32, -1 / 8, -3 / 16, 7 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})


minetest.register_node("streets:rrxing_middle_center_off", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_center_back.png",
		"streets_rrxing_middle_center_back.png",
		"streets_rrxing_middle_center_back.png",
		"streets_rrxing_middle_center_off.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -1 / 2, -1 / 2, -1 / 16, 1 / 2, 1 / 2, -1 / 16 },
			{ -1 / 2, -5 / 16, -1 / 16, -3 / 16, 1 / 16, 3 / 16 },
			{ 3 / 16, -5 / 16, -1 / 16, 1 / 2, 1 / 16, 3 / 16 },
			{ -3 / 16, -3 / 16, -1 / 16, 3 / 16, -1 / 16, 1 / 8 },
			{ -1 / 2, 1 / 32, -5 / 16, -7 / 32, 3 / 32, -1 / 16 },
			{ -7 / 32, -1 / 8, -3 / 16, -5 / 32, 1 / 32, -1 / 16 },
			{ 7 / 32, 1 / 32, -5 / 16, 1 / 2, 3 / 32, -1 / 16 },
			{ 5 / 32, -1 / 8, -3 / 16, 7 / 32, 1 / 32, -1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_middle", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_middle_back.png",
		"streets_rrxing_middle_back.png",
		"streets_rrxing_middle_back.png",
		"streets_rrxing_middle.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 3, not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -3 / 8, -3 / 8, -1 / 8, 3 / 8, 3 / 8, -1 / 16 },
			{ -1 / 8, -1 / 8, -1 / 16, 1 / 8, 1 / 8, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:rrxing_bottom", {
	description = "Railroad Crossing Signal",
	inventory_image = "streets_rrxing_inv.png",
	wield_image = "streets_rrxing_inv.png",
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 3 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, 0, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -1 / 2, -1 / 2, -1 / 4, 1 / 2, -3 / 8, 1 / 4 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, 0, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			-- top
			{ -1 / 8, 0 + 3, -1 / 8, 1 / 8, 3 / 8 + 3, 1 / 8 },
			{ -1 / 4, 1 / 8 + 3, -1 / 4, 1 / 4, 1 / 4 + 3, 1 / 4 },
			{ -1 / 8, -1 / 2 + 3, -1 / 16 + 0.01, 1 / 8, -1 / 4 + 3, 1 / 8 },
			-- middle center, left and right
			{ -9 / 16, -5 / 16 + 2, -1 / 16, -3 / 16, 1 / 16 + 2, 3 / 16 },
			{ 3 / 16, -5 / 16 + 2, -1 / 16, 9 / 16, 1 / 16 + 2, 3 / 16 },

			{ -3 / 16, -3 / 16 + 2, -1 / 16 + 0.01, 3 / 16, -1 / 16 + 2, 1 / 8 },

			{ -1 / 2, 1 / 32 + 2, -5 / 16, -7 / 32, 3 / 32 + 2, -1 / 16 - 0.01 },
			{ -7 / 32, -1 / 8 + 2, -3 / 16, -5 / 32, 1 / 32 + 2, -1 / 16 - 0.01 },
			{ 13 / 32 - 1, -1 / 8 + 2, -3 / 16, 15 / 32 - 1, 1 / 32 + 2, -1 / 16 - 0.01 },

			{ 7 / 32, 1 / 32 + 2, -5 / 16, 1 / 2, 3 / 32 + 2, -1 / 16 - 0.01 },
			{ 5 / 32, -1 / 8 + 2, -3 / 16, 7 / 32, 1 / 32 + 2, -1 / 16 - 0.01 },
			{ -15 / 32 + 1, -1 / 8 + 2, -3 / 16, -13 / 32 + 1, 1 / 32 + 2, -1 / 16 - 0.01 },
			-- middle
			{ -3 / 8, -3 / 8 + 1, -1 / 8, 3 / 8, 3 / 8 + 1, -1 / 16 },
			{ -1 / 8, -1 / 8 + 1, -1 / 16, 1 / 8, 1 / 8 + 1, 1 / 8 },
			-- bottom
			{ -1 / 2, -1 / 2, -1 / 4, 1 / 2, -3 / 8, 1 / 4 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, 0, 1 / 8 },
			-- post
			{ -1 / 16, 0, -1 / 16, 1 / 16, 3, 1 / 16 }
		}
	},
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		local param2 = node.param2

		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")

		pos.y = pos.y + 1
		node.name = "streets:rrxing_middle"
		minetest.set_node(pos, node)

		pos.y = pos.y + 2
		node.name = "streets:rrxing_top"
		minetest.set_node(pos, node)

		pos.y = pos.y - 1
		node.name = "streets:rrxing_middle_center_off"
		minetest.set_node(pos, node)

		left_light_direction(pos, param2)
		node.name = "streets:rrxing_middle_left_off"
		minetest.set_node(pos, node)

		right_light_direction(pos, param2)
		node.name = "streets:rrxing_middle_right_off"
		minetest.set_node(pos, node)
	end,
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		local param2 = node.param2
		pos.y = pos.y + 2
		stop_bell(pos, node)
		pos.y = pos.y - 2

		for i = 1, 3 do
			pos.y = pos.y + 1
			minetest.remove_node(pos)
		end

		pos.y = pos.y - 1

		left_light_direction(pos, param2)
		minetest.remove_node(pos)

		right_light_direction(pos, param2)
		minetest.remove_node(pos)
	end,
	on_punch = function(pos, node)
		toggle_lights(pos, node)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if (fields.channel) then
			minetest.get_meta(pos):set_string("channel", fields.channel)
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, msg)
				local setchan = minetest.get_meta(pos):get_string("channel")
				if setchan ~= channel then
					return
				end
				if (msg == "bell_on") then
					pos.y = pos.y + 2
					play_bell(pos)
				elseif (msg == "bell_off") then
					pos.y = pos.y + 2
					stop_bell(pos)
				elseif (msg == "lights_on") then
					pos.y = pos.y + 2
					lights_on(pos)
				elseif (msg == "lights_off") then
					pos.y = pos.y + 2
					lights_off(pos)
				end
			end
		}
	}
})

local function move_arm(pos)
	local node = minetest.get_node(pos)
	local param2 = node.param2

	if param2 == 0 then
		dir = "z-"
	elseif param2 == 1 then
		dir = "x-"
	elseif param2 == 2 then
		dir = "z+"
	elseif param2 == 3 then
		dir = "x+"
	end

	minetest.sound_play("streets_rrxing_gate", {
		pos = pos,
		gain = 0.66,
		max_hear_distance = 20
	})

	if node.name == "streets:rrgate_mech_down" then
		minetest.set_node(pos, { name = "streets:rrgate_mech_up", param2 = node.param2 })

		if dir == "x+" then
			for i = 1, 10 do
				pos.x = pos.x + 1
				if (string.match(minetest.get_node(pos).name, "streets:rrgate_lightfirst")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_end")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_darkfirst")) == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				node.name = "streets:rrgate_up"
				minetest.set_node({ x = pos.x - i, y = pos.y + i, z = pos.z }, node)
			end
		elseif dir == "x-" then
			for i = 1, 10 do
				pos.x = pos.x - 1
				if (string.match(minetest.get_node(pos).name, "streets:rrgate_lightfirst")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_end")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_darkfirst")) == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				node.name = "streets:rrgate_up"
				minetest.set_node({ x = pos.x + i, y = pos.y + i, z = pos.z }, node)
			end
		elseif dir == "z+" then
			for i = 1, 10 do
				pos.z = pos.z + 1
				if (string.match(minetest.get_node(pos).name, "streets:rrgate_lightfirst")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_end")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_darkfirst")) == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				node.name = "streets:rrgate_up"
				minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z - i }, node)
			end
		elseif dir == "z-" then
			for i = 1, 10 do
				pos.z = pos.z - 1
				if (string.match(minetest.get_node(pos).name, "streets:rrgate_lightfirst")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_end")
						or string.match(minetest.get_node(pos).name, "streets:rrgate_darkfirst")) == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				node.name = "streets:rrgate_up"
				minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z + i }, node)
			end
		end

	elseif node.name == "streets:rrgate_mech_up" then
		minetest.swap_node(pos, { name = "streets:rrgate_mech_down", param2 = node.param2 })
		if dir == "x+" then
			for i = 1, 10 do
				pos.y = pos.y + 1
				if string.match(minetest.get_node(pos).name, "streets:rrgate_up") == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				if i % 2 == 1 then
					node.name = "streets:rrgate_lightfirst"
				else
					node.name = "streets:rrgate_darkfirst"
				end
				if minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name ~= "streets:rrgate_up" then
					node.name = "streets:rrgate_end"
				end
				minetest.set_node({ x = pos.x + i, y = pos.y - i, z = pos.z }, node)
			end
		elseif dir == "x-" then
			for i = 1, 10 do
				pos.y = pos.y + 1
				if string.match(minetest.get_node(pos).name, "streets:rrgate_up") == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				if i % 2 == 1 then
					node.name = "streets:rrgate_lightfirst"
				else
					node.name = "streets:rrgate_darkfirst"
				end
				if minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name ~= "streets:rrgate_up" then
					node.name = "streets:rrgate_end"
				end
				minetest.set_node({ x = pos.x - i, y = pos.y - i, z = pos.z }, node)
			end
		elseif dir == "z+" then
			for i = 1, 10 do
				pos.y = pos.y + 1
				if string.match(minetest.get_node(pos).name, "streets:rrgate_up") == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				if i % 2 == 1 then
					node.name = "streets:rrgate_lightfirst"
				else
					node.name = "streets:rrgate_darkfirst"
				end
				if minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name ~= "streets:rrgate_up" then
					node.name = "streets:rrgate_end"
				end
				minetest.set_node({ x = pos.x, y = pos.y - i, z = pos.z + i }, node)
			end
		elseif dir == "z-" then
			for i = 1, 10 do
				pos.y = pos.y + 1
				if string.match(minetest.get_node(pos).name, "streets:rrgate_up") == nil then
					break
				end
				minetest.set_node(pos, { name = "air" })
				if i % 2 == 1 then
					node.name = "streets:rrgate_lightfirst"
				else
					node.name = "streets:rrgate_darkfirst"
				end
				if minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name ~= "streets:rrgate_up" then
					node.name = "streets:rrgate_end"
				end
				minetest.set_node({ x = pos.x, y = pos.y - i, z = pos.z - i }, node)
			end
		end
	end
end

minetest.register_node("streets:rrgate_mech_down", {
	description = "Railroad Crossing Gate Mechanism",
	tiles = {
		"streets_rrgate_mech_down_top.png",
		"streets_rrgate_mech_down_bottom.png",
		"streets_rrgate_mech_down_right.png",
		"streets_rrgate_mech_down_left.png",
		"streets_rrgate_mech_down_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 4, -1 / 4, 1 / 4, 1 / 4, 1 / 4 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, -1 / 4, 1 / 8 },

			{ -3 / 8, -1 / 2, -1 / 2, -1 / 4, -1 / 4, 1 / 8 },
			{ -3 / 8, -1 / 2, -1 / 8, -1 / 4, 1 / 8, 1 / 8 },
			{ -3 / 8, -1 / 8, -1 / 8, -1 / 4, 1 / 8, 1 / 2 },
			{ -1 / 2, -3 / 16, 1 / 4, -3 / 8, 3 / 16, 1 / 2 },
			{ -1 / 2, -1 / 8, 3 / 16, -3 / 8, 1 / 8, 1 / 2 },
			{ -1 / 2, -1 / 16, 1 / 8, -3 / 8, 1 / 16, 1 / 2 },

			{ 1 / 4, -1 / 2, -1 / 2, 3 / 8, -1 / 4, 1 / 8 },
			{ 1 / 4, -1 / 2, -1 / 8, 3 / 8, 1 / 8, 1 / 8 },
			{ 1 / 4, -1 / 8, -1 / 8, 3 / 8, 1 / 8, 1 / 2 },
			{ 3 / 8, -3 / 16, 1 / 4, 1 / 2, 3 / 16, 1 / 2 },
			{ 3 / 8, -1 / 8, 3 / 16, 1 / 2, 1 / 8, 1 / 2 },
			{ 3 / 8, -1 / 16, 1 / 8, 1 / 2, 1 / 16, 1 / 2 },

			{ -3 / 8, -1 / 2, -1 / 2, 3 / 8, -1 / 4, -3 / 8 },

			{ -7 / 16, -1 / 16, -1 / 16, 7 / 16, 1 / 16, 1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 4, -1 / 4, 1 / 4, 1 / 4, 1 / 4 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, -1 / 4, 1 / 8 },

			{ -3 / 8, -1 / 2, -1 / 2, -1 / 4, -1 / 4, 1 / 8 },
			{ -3 / 8, -1 / 2, -1 / 8, -1 / 4, 1 / 8, 1 / 8 },
			{ -3 / 8, -1 / 8, -1 / 8, -1 / 4, 1 / 8, 1 / 2 },
			{ -1 / 2, -3 / 16, 1 / 4, -3 / 8, 3 / 16, 1 / 2 },
			{ -1 / 2, -1 / 8, 3 / 16, -3 / 8, 1 / 8, 1 / 2 },
			{ -1 / 2, -1 / 16, 1 / 8, -3 / 8, 1 / 16, 1 / 2 },

			{ 1 / 4, -1 / 2, -1 / 2, 3 / 8, -1 / 4, 1 / 8 },
			{ 1 / 4, -1 / 2, -1 / 8, 3 / 8, 1 / 8, 1 / 8 },
			{ 1 / 4, -1 / 8, -1 / 8, 3 / 8, 1 / 8, 1 / 2 },
			{ 3 / 8, -3 / 16, 1 / 4, 1 / 2, 3 / 16, 1 / 2 },
			{ 3 / 8, -1 / 8, 3 / 16, 1 / 2, 1 / 8, 1 / 2 },
			{ 3 / 8, -1 / 16, 1 / 8, 1 / 2, 1 / 16, 1 / 2 },

			{ -3 / 8, -1 / 2, -1 / 2, 3 / 8, -1 / 4, -3 / 8 },

			{ -7 / 16, -1 / 16, -1 / 16, 7 / 16, 1 / 16, 1 / 16 }
		}
	},
	after_place_node = function(pos)
		local node = minetest.get_node(pos)
		node.name = "streets:rrgate_mech_bottom"
		minetest.set_node(pos, node)
		pos.y = pos.y + 1
		node.name = "streets:rrgate_mech_down"
		minetest.set_node(pos, node)
	end,
	after_dig_node = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, { name = "air" })
	end,
	on_punch = function(pos)
		move_arm(pos)
	end
})

minetest.register_node("streets:rrgate_mech_up", {
	tiles = {
		"streets_rrgate_mech_down_front.png", --A bit "different", I know, but that texture works
		"streets_rrgate_mech_up_bottom.png",
		"streets_rrgate_mech_up_right.png",
		"streets_rrgate_mech_up_left.png",
		"streets_rrgate_mech_up_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:rrgate_mech_down",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 4, -1 / 4, 1 / 4, 1 / 4, 1 / 4 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, -1 / 4, 1 / 8 },

			{ -3 / 8, -1 / 8, -1 / 2, -1 / 4, 1 / 2, -1 / 4 },
			{ -3 / 8, -1 / 8, -1 / 2, -1 / 4, 1 / 8, 1 / 8 },
			{ -3 / 8, -1 / 2, -1 / 8, -1 / 4, 1 / 8, 1 / 8 },
			{ -1 / 2, -1 / 2, -3 / 16, -3 / 8, -1 / 4, 3 / 16 },
			{ -1 / 2, -1 / 2, -1 / 8, -3 / 8, -3 / 16, 1 / 8 },
			{ -1 / 2, -1 / 2, -1 / 16, -3 / 8, -1 / 8, 1 / 16 },

			{ 1 / 4, -1 / 8, -1 / 2, 3 / 8, 1 / 2, -1 / 4 },
			{ 1 / 4, -1 / 8, -1 / 2, 3 / 8, 1 / 8, 1 / 8 },
			{ 1 / 4, -1 / 2, -1 / 8, 3 / 8, 1 / 8, 1 / 8 },
			{ 3 / 8, -1 / 2, -3 / 16, 1 / 2, -1 / 4, 3 / 16 },
			{ 3 / 8, -1 / 2, -1 / 8, 1 / 2, -3 / 16, 1 / 8 },
			{ 3 / 8, -1 / 2, -1 / 16, 1 / 2, -1 / 8, 1 / 16 },

			{ -3 / 8, 3 / 8, -1 / 2, 3 / 8, 1 / 2, -1 / 4 },

			{ -7 / 16, -1 / 16, -1 / 16, 7 / 16, 1 / 16, 1 / 16 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 4, -1 / 4, 1 / 4, 1 / 4, 1 / 4 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, -1 / 4, 1 / 8 },

			{ -3 / 8, -1 / 8, -1 / 2, -1 / 4, 1 / 2, -1 / 4 },
			{ -3 / 8, -1 / 8, -1 / 2, -1 / 4, 1 / 8, 1 / 8 },
			{ -3 / 8, -1 / 2, -1 / 8, -1 / 4, 1 / 8, 1 / 8 },
			{ -1 / 2, -1 / 2, -3 / 16, -3 / 8, -1 / 4, 3 / 16 },
			{ -1 / 2, -1 / 2, -1 / 8, -3 / 8, -3 / 16, 1 / 8 },
			{ -1 / 2, -1 / 2, -1 / 16, -3 / 8, -1 / 8, 1 / 16 },

			{ 1 / 4, -1 / 8, -1 / 2, 3 / 8, 1 / 2, -1 / 4 },
			{ 1 / 4, -1 / 8, -1 / 2, 3 / 8, 1 / 8, 1 / 8 },
			{ 1 / 4, -1 / 2, -1 / 8, 3 / 8, 1 / 8, 1 / 8 },
			{ 3 / 8, -1 / 2, -3 / 16, 1 / 2, -1 / 4, 3 / 16 },
			{ 3 / 8, -1 / 2, -1 / 8, 1 / 2, -3 / 16, 1 / 8 },
			{ 3 / 8, -1 / 2, -1 / 16, 1 / 2, -1 / 8, 1 / 16 },

			{ -3 / 8, 3 / 8, -1 / 2, 3 / 8, 1 / 2, -1 / 4 },

			{ -7 / 16, -1 / 16, -1 / 16, 7 / 16, 1 / 16, 1 / 16 }
		}
	},
	after_dig_node = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, { name = "air" })
	end,
	on_punch = function(pos)
		move_arm(pos)
	end
})

minetest.register_node("streets:rrgate_mech_bottom", {
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png",
		"streets_rrxing_bottom.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:rrgate_mech_down",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -1 / 2, -1 / 2, -1 / 4, 1 / 2, -3 / 8, 1 / 4 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, 0, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
			{ -1 / 2, -1 / 2, -1 / 4, 1 / 2, -3 / 8, 1 / 4 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 },
			{ -1 / 8, -1 / 2, -1 / 8, 1 / 8, 0, 1 / 8 }
		}
	},
	after_dig_node = function(pos)
		pos.y = pos.y + 1
		minetest.set_node(pos, { name = "air" })
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
	end,
	on_receive_fields = function(pos, formname, fields)
		if (fields.channel) then
			minetest.get_meta(pos):set_string("channel", fields.channel)
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, msg)
				local setchan = minetest.get_meta(pos):get_string("channel")
				if setchan ~= channel then
					return
				end
				pos.y = pos.y + 1
				local mechnode = minetest.get_node(pos)
				if ((msg == "up" and mechnode.name == "streets:rrgate_mech_down") or (msg == "down" and mechnode.name == "streets:rrgate_mech_up")) then
					move_arm(pos)
				end
			end
		}
	},
})

minetest.register_node("streets:rrgate_lightfirst", {
	description = "Railroad Crossing Gate",
	tiles = {
		"streets_rrgate_top.png",
		"streets_rrgate_side.png",
		{ name = "streets_rrgate_lightfirst.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } },
		{ name = "streets_rrgate_lightfirst.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } },
		"streets_rrgate_side.png",
		"streets_rrgate_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1 },
	light_source = 12,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -7 / 16, 1 / 2 },
			{ -1 / 8, -5 / 16, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ -1 / 8, -1 / 2, -1 / 2, -1 / 16, -1 / 4, 1 / 2 },
			{ 1 / 16, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ 0, -1 / 4, -1 / 8, 0, 0, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 }
		}
	}
})

minetest.register_node("streets:rrgate_darkfirst", {
	tiles = {
		"streets_rrgate_top.png",
		"streets_rrgate_side.png",
		{ name = "streets_rrgate_darkfirst.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } },
		{ name = "streets_rrgate_darkfirst.png", animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 } },
		"streets_rrgate_side.png",
		"streets_rrgate_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:rrgate_lightfirst",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -7 / 16, 1 / 2 },
			{ -1 / 8, -5 / 16, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ -1 / 8, -1 / 2, -1 / 2, -1 / 16, -1 / 4, 1 / 2 },
			{ 1 / 16, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ 0, -1 / 4, -1 / 8, 0, 0, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 }
		}
	}
})

minetest.register_node("streets:rrgate_end", {
	tiles = {
		"streets_rrgate_top.png",
		"streets_rrgate_side.png",
		"streets_rrgate_end.png",
		"streets_rrgate_end.png",
		"streets_rrgate_side.png",
		"streets_rrgate_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:rrgate_lightfirst",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -7 / 16, 1 / 2 },
			{ -1 / 8, -5 / 16, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ -1 / 8, -1 / 2, -1 / 2, -1 / 16, -1 / 4, 1 / 2 },
			{ 1 / 16, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 },
			{ 0, -1 / 4, -1 / 8, 0, 0, 1 / 8 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, -1 / 4, 1 / 2 }
		}
	}
})

minetest.register_node("streets:rrgate_up", {
	tiles = {
		"streets_rrgate_side.png",
		"streets_rrgate_side.png",
		"streets_rrgate_up_left.png",
		"streets_rrgate_up_right.png",
		"streets_rrgate_top.png",
		"streets_rrgate_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:rrgate_lightfirst",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, 1 / 2, -7 / 16 },
			{ -1 / 8, -1 / 2, -5 / 16, 1 / 8, 1 / 2, -1 / 4 },
			{ -1 / 8, -1 / 2, -1 / 2, -1 / 16, 1 / 2, -1 / 4 },
			{ 1 / 16, -1 / 2, -1 / 2, 1 / 8, 1 / 2, -1 / 4 },
			{ 0, -1 / 8, -1 / 4, 0, 1 / 8, 0 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 8, -1 / 2, -1 / 2, 1 / 8, 1 / 2, -1 / 4 }
		}
	}
})

minetest.register_craft({
	output = "streets:rrxing_bottom",
	recipe = {
		{ "", "default:copper_ingot", "" },
		{ "wool:red", "default:sign_wall_wood", "wool:red" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:rrgate_mech_down",
	recipe = {
		{ "", "default:copper_ingot", "streets:rrgate_lightfirst" },
		{ "", "default:steel_ingot", "" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:rrgate_lightfirst 4",
	recipe = {
		{ "default:steel_ingot", "default:torch", "default:steel_ingot" },
		{ "dye:red", "dye:white", "dye:red" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
	}
})
