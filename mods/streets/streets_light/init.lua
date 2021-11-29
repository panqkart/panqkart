--[[
	## StreetsMod 2.0 ##
	Submod: light
	Optional: true
]]

local rules = {
	{ x = 0, y = 0, z = -1 },
	{ x = 0, y = 0, z = 1 },
	{ x = 1, y = 0, z = 0 },
	{ x = -1, y = 0, z = 0 },
	{ x = 0, y = -1, z = 0 },
	{ x = 0, y = 1, z = 0 },
	{ x = 1, y = 1, z = 0 },
	{ x = 1, y = -1, z = 0 },
	{ x = -1, y = 1, z = 0 },
	{ x = -1, y = -1, z = 0 },
	{ x = 0, y = 1, z = 1 },
	{ x = 0, y = -1, z = 1 },
	{ x = 0, y = 1, z = -1 },
	{ x = 0, y = -1, z = -1 }
}

local function update_formspec(pos)
	local node = minetest.get_node(pos)
	if not minetest.registered_nodes[node.name].groups.streets_light then
		return
	end
	local meta = minetest.get_meta(pos)
	local mode = meta:get_string("mode")

	local fs = "size[9,6;]"
	fs = fs .. "label[0,0;Street Light Setup]"
	fs = fs .. "box[0,0.4;8.6,0.05;#FFFFFF]"
	fs = fs .. "box[2.6,0.6;0.05,5.4;#FFFFFF]"
	fs = fs .. "label[0,0.6;Select Mode:]"
	fs = fs .. "button[0,1.25;2.5,1;time;Time]"
	fs = fs .. "button[0,2.25;2.5,1;digiline;Digiline]"
	fs = fs .. "button[0,3.25;2.5,1;mesecons;Mesecons]"
	fs = fs .. "button[0,4.25;2.5,1;manual;Manual]"

	if mode == "time" then
		fs = fs .. "label[3,0.6;Selected Mode: Time]"
		fs = fs .. "field[3.5,2;2,1;time_on;Turn-On-Time;${time_on}]"
		fs = fs .. "button[5,1.7;1,1;submit_time;OK]"
		fs = fs .. "field[3.5,4;2,1;time_off;Turn-Off-Time;${time_off}]"
		fs = fs .. "button[5,3.7;1,1;submit_time;OK]"
	elseif mode == "digiline" then
		fs = fs .. "label[3,0.6;Selected Mode: Digiline]"
		fs = fs .. "label[3,2;Send digiline message 'ON' to turn the lantern on.]"
		fs = fs .. "label[3,2.3;Send digiline message 'OFF' to turn the lantern off.]"
		fs = fs .. "field[3.5,4;2,1;channel;Digiline Channel;${channel}]"
		fs = fs .. "button[5,3.7;1,1;submit_channel;OK]"
	elseif mode == "mesecons" then
		fs = fs .. "label[3,0.6;Selected Mode: Mesecons]"
		fs = fs .. "label[3,2;The lantern is on when receiving mesecons signal.]"
		fs = fs .. "label[3,2.3;The lantern is off when not receiving mesecons signal.]"
	elseif mode == "manual" then
		fs = fs .. "label[3,0.6;Selected Mode: Manual]"
		fs = fs .. "label[3,2;Punch the lantern to change the state (on/off).]"
	end
	meta:set_string("formspec", fs)
end

local on_receive_fields = function(pos, formname, fields, sender)
	local name = sender:get_player_name()
	if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
		minetest.chat_send_player(name, core.colorize("#FF5300", "You don't have access to this lantern. Stop trying to configure it!"))
		minetest.record_protection_violation(pos, name)
		return
	end

	local meta = minetest.get_meta(pos)

	if fields.time then
		meta:set_string("mode", "time")
	elseif fields.digiline then
		meta:set_string("mode", "digiline")
	elseif fields.mesecons then
		meta:set_string("mode", "mesecons")
	elseif fields.manual then
		meta:set_string("mode", "manual")
	end

	if fields.submit_channel then
		meta:set_string("channel", fields.channel)
	elseif fields.submit_time then
		meta:set_int("time_on", tonumber(fields.time_on))
		meta:set_int("time_off", tonumber(fields.time_off))
	end

	update_formspec(pos)
end

local on_digiline_receive = function(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local mode = meta:get_string("mode")
	local state = node.name:find("off") and "off" or "on"
	local newnode = node
	if type(msg) == "string" then
		msg = msg:lower()
		if mode == "digiline" and channel == meta:get_string("channel") then
			if state == "on" then
				if msg == "off" then
					newnode.name = newnode.name:gsub("_on", "_off")
					minetest.swap_node(pos, newnode)
				end
			else
				if msg == "on" then
					newnode.name = newnode.name:gsub("_off", "_on")
					minetest.swap_node(pos, newnode)
				end
			end
		end
	end
end

local on_punch = function(pos, node, player, pointed_thing)
	local player_name = player:get_player_name()
	if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
		minetest.chat_send_player(player_name, core.colorize("#FF5300", "You don't have access to this lantern. Stop trying to turn it on/off!"))
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local meta = minetest.get_meta(pos)
	local mode = meta:get_string("mode")
	local state = node.name:find("off") and "off" or "on"
	local newnode = node
	if mode == "manual" then
		if state == "on" then
			newnode.name = newnode.name:gsub("_on", "_off")
			minetest.swap_node(pos, newnode)
		else
			newnode.name = newnode.name:gsub("_off", "_on")
			minetest.swap_node(pos, newnode)
		end
	end
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("mode", "time")
	meta:set_string("channel", "streetlight")
	meta:set_int("time_on", "18500")
	meta:set_string("time_off", "5500")
	update_formspec(pos)
end

local def_digiline =
{
	receptor = {},
	effector = {
		action = on_digiline_receive,
		rules = rules
	},
	wire = {
		rules = rules
	}
}

local def_mesecons =
{
	effector = {
		action_on = function(pos, node)
			local meta = minetest.get_meta(pos)
			local state = node.name:find("off") and "off" or "on"
			if meta:get_string("mode") == "mesecons" and state == "off" then
				local newnode = node
				newnode.name = newnode.name:gsub("_off", "_on")
				minetest.swap_node(pos, newnode)
			end
		end,
		action_off = function(pos, node)
			local meta = minetest.get_meta(pos)
			local state = node.name:find("off") and "off" or "on"
			if meta:get_string("mode") == "mesecons" and state == "on" then
				local newnode = node
				newnode.name = newnode.name:gsub("_on", "_off")
				minetest.swap_node(pos, newnode)
			end
		end,
		rules = rules
	},
	wire = {
		rules = rules
	}
}





minetest.register_abm({
	nodenames = { "group:streets_light" },
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_string("mode")
		local state = node.name:find("off") and "off" or "on"
		local newnode = node
		if mode == "time" then
			local time = minetest.get_timeofday() * 24000
			if state == "on" then
				if time < meta:get_int("time_on") and time > meta:get_int("time_off") then
					newnode.name = newnode.name:gsub("_on", "_off")
					minetest.swap_node(pos, newnode)
				end
			else
				if time > meta:get_int("time_on") or time < meta:get_int("time_off") then
					newnode.name = newnode.name:gsub("_off", "_on")
					minetest.swap_node(pos, newnode)
				end
			end
		end
	end,
})






minetest.register_node(":streets:light_vertical_off", {
	description = "Streets Light Vertical",
	tiles = { "streets_pole.png", "streets_pole.png", "streets_light_vertical_off.png", "streets_light_vertical_off.png", "streets_light_vertical_off.png", "streets_light_vertical_off.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1 },
	light_source = 0,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -5 / 16, -0.5, -5 / 16, 5 / 16, 0.5, 5 / 16 },
		}
	},
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})

minetest.register_node(":streets:light_vertical_on", {
	tiles = { "streets_pole.png", "streets_pole.png", "streets_light_vertical_on.png", "streets_light_vertical_on.png", "streets_light_vertical_on.png", "streets_light_vertical_on.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1, not_in_creative_inventory = 1 },
	light_source = 14,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -5 / 16, -0.5, -5 / 16, 5 / 16, 0.5, 5 / 16 },
		}
	},
	drop = "streets:light_vertical_off",
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})


minetest.register_node(":streets:light_horizontal_off", {
	description = "Streets Light Horizontal",
	tiles = { "streets_pole.png", "streets_light_horizontal_off_bottom.png", "streets_light_horizontal_off_side.png", "streets_light_horizontal_off_side.png", "streets_light_horizontal_off_side.png", "streets_light_horizontal_off_side.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1 },
	light_source = 0,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -3 / 16, -3 / 16, -0.5, 3 / 16, 3 / 16, 0.5 },
		}
	},
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})

minetest.register_node(":streets:light_horizontal_on", {
	tiles = { "streets_pole.png", "streets_light_horizontal_on_bottom.png", "streets_light_horizontal_on_side.png", "streets_light_horizontal_on_side.png", "streets_light_horizontal_on_side.png", "streets_light_horizontal_on_side.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1, not_in_creative_inventory = 1 },
	light_source = 14,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -3 / 16, -3 / 16, -0.5, 3 / 16, 3 / 16, 0.5 },
		}
	},
	drop = "streets:light_horizontal_off",
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})


minetest.register_node(":streets:light_hanging_off", {
	description = "Streets Light Hanging",
	tiles = { "streets_pole.png", "streets_light_horizontal_off_bottom.png", "streets_light_hanging_off_side.png", "streets_light_hanging_off_side.png", "streets_light_hanging_off_side.png", "streets_light_hanging_off_side.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1 },
	light_source = 0,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -3 / 16, 2 / 16, -0.5, 3 / 16, 0.5, 0.5 },
		}
	},
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})

minetest.register_node(":streets:light_hanging_on", {
	tiles = { "streets_pole.png", "streets_light_horizontal_on_bottom.png", "streets_light_hanging_on_side.png", "streets_light_hanging_on_side.png", "streets_light_hanging_on_side.png", "streets_light_hanging_on_side.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, streets_light = 1, not_in_creative_inventory = 1 },
	light_source = 14,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -3 / 16, 2 / 16, -0.5, 3 / 16, 0.5, 0.5 },
		}
	},
	drop = "streets:light_hanging_off",
	on_construct = on_construct,
	on_punch = on_punch,
	on_receive_fields = on_receive_fields,
	digiline = def_digiline,
	mesecons = def_mesecons
})

minetest.register_craft({
	output = "streets:light_vertical_off 3",
	recipe = {
		{ "", "default:steel_ingot", "" },
		{ "", "default:meselamp", "" },
		{ "", "default:steel_ingot", "" }
	}
})

minetest.register_craft({
	output = "streets:light_horizontal_off 3",
	recipe = {
		{ "default:steel_ingot", "default:meselamp", "default:steel_ingot" },
	}
})

minetest.register_craft({
	output = "streets:light_hanging_off 3",
	recipe = {
		{ "", "default:stick", "" },
		{ "default:steel_ingot", "default:meselamp", "default:steel_ingot" },
	}
})
