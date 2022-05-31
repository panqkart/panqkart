--[[
	## StreetsMod 2.0 ##
	Submod: matrix_screen
	Optional: true
]]

-- This submod was made by HybridDog and modified by Thomas S.

local matrix_px = 16

-- gets the object at pos
local function get_screen(pos)
	local object
	local objects = minetest.get_objects_inside_radius(pos, 0.5) or {}
	for _, obj in pairs(objects) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.name == "streets:matrix_screen_lights" then
				-- Remove duplicates
				if object then
					obj:remove()
				else
					object = obj
				end
			end
		end
	end
	return object
end

-- used to get the texture for the object
local function generate_textures(data)
	local texture, n = { "streets_matrix_screen_front.png^[combine:" .. matrix_px .. "x" .. matrix_px }, 2
	for y = 1, matrix_px do
		local xs = data[y]
		for x = 1, matrix_px do
			if xs[x] then
				texture[n] = ":" .. x - 1 .. "," .. y - 1 .. "=streets_matrix_px.png"
				n = n + 1
			end
		end
	end
	texture[n] = "^streets_matrix_screen_lines.png"
	texture = table.concat(texture, "")
	return { texture, texture, texture, texture, texture, texture }
end

-- updates texture of screen
local function update_screen(pos, data)
	local obj = get_screen(pos) or minetest.add_entity(pos, "streets:matrix_screen_lights")
	obj:set_properties({ textures = generate_textures(data) })
end

-- returns an empty toggleds table
local function new_toggleds()
	local t = {}
	for y = 1, matrix_px do
		t[y] = {}
	end
	return t
end

-- gets the toggleds of the node from meta
local function get_data(meta)
	local data = minetest.deserialize(minetest.decompress(meta:get_string("toggleds")))
	if type(data) ~= "table" then
		data = new_toggleds()
	end
	return data
end

-- update toggleds via a table sent by digiline
local function apply_changes(toggleds, t)
	if type(t) ~= "table" then
		return false, "matrix screen: got unsupported thing: " .. dump(t)
	end
	for y = 1, matrix_px do
		toggleds[y] = {}
	end
	for y = 1, 16 do
		local xs = t[y]
		if type(xs) == "table" then
			for x = 1, 16 do
				local enabled = xs[x]
				if enabled and enabled ~= 0 then
					toggleds[y][x] = true
				elseif enabled == false or enabled == 0 then
					toggleds[y][x] = nil
				end
			end
		elseif type(xs) == "number" then
			for x = 1, 16 do
				if math.floor(xs/2^(16-x))%2 == 1 then
					toggleds[y][x] = true
				else
					toggleds[y][x] = nil
				end
			end
		end
	end
	return true
end

-- sets the toggleds of the node to meta
local function set_data(meta, toggleds)
	meta:set_string("toggleds", minetest.compress(minetest.serialize(toggleds)))
end

minetest.register_node("streets:matrix_screen_base", {
	description = "digiline controllable matrix screen",
	tiles = { "streets_matrix_screen_front.png" },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 3, oddly_breakable_by_hand = 2 },
	sounds = default.node_sound_stone_defaults(),
	light_source = 14,
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.49, 0.5, 0.5, 0.5 },
		},
	},
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
			minetest.record_protection_violation(pos, name)
			return
		end
		if (fields.channel) then
			minetest.get_meta(pos):set_string("channel", fields.channel)
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
		meta:set_string("channel", "matrix_screen")
		minetest.add_entity(pos, "streets:matrix_screen_lights")
	end,
	on_destruct = function(pos)
		local obj = get_screen(pos)
		if obj then
			obj:remove()
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, t)
				local meta = minetest.get_meta(pos)
				local toggleds = get_data(meta)
				if channel == meta:get_string("channel") .. "_reset" then
					for y = 1, matrix_px do
						toggleds[y] = {}
					end
					set_data(meta, toggleds)
					update_screen(pos, toggleds)
				end
				if channel ~= meta:get_string("channel") then
					return
				end
				apply_changes(toggleds, t)
				set_data(meta, toggleds)
				update_screen(pos, toggleds)
			end,
			rules = {
				{ x = 1, y = 0, z = 0 },
				{ x = 1, y = 1, z = 0 },
				{ x = 1, y = -1, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = -1, y = 1, z = 0 },
				{ x = -1, y = -1, z = 0 },
				{ x = 0, y = 1, z = 0 },
				{ x = 0, y = 1, z = 1 },
				{ x = 0, y = 1, z = -1 },
				{ x = 0, y = -1, z = 0 },
				{ x = 0, y = -1, z = 1 },
				{ x = 0, y = -1, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 0, y = 0, z = -1 },
			}
		},
	},
})

-- ensure the screen existence
minetest.register_abm({
	interval = 5,
	chance = 1,
	nodenames = { "streets:matrix_screen_base" },
	action = function(pos, node)
		if not get_screen(pos) then
			local toggleds = get_data(minetest.get_meta(pos))
			update_screen(pos, toggleds)
			minetest.log("info", "[streets] matrix screen object was missing")
		end
	end,
})

-- the screen
minetest.register_entity("streets:matrix_screen_lights", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	physical = false,
	visual = "cube",
	visual_size = { x = 0.99, y = 0.99 },
	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		if not vector.equals(pos, vector.round(pos)) then
			self.object:remove()
			return
		end
		local node = minetest.get_node(pos)
		if node.name ~= "streets:matrix_screen_base"
				and node.name ~= "ignore" then
			self.object:remove()
			return
		end
		minetest.after(0, function(position)
			update_screen(position, get_data(minetest.get_meta(position)))
		end, pos)
	end,
})

minetest.register_craft({
	output = "streets:matrix_screen_base",
	recipe = {
		{ "dye:yellow", "default:steel_ingot", "dye:yellow" },
		{ "default:steel_ingot", "digilines:lcd", "default:steel_ingot" },
		{ "dye:yellow", "default:steel_ingot", "dye:yellow" },
	}
})
