--[[
Adds nodes that look like other nodes (or just new ones) with different functionalities.

Copyright (C) 2022-2023 David Leal (halfpacho@gmail.com)
Copyright (C) Various other Minetest developers/contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA
--]]

local S = minetest.get_translator("default") -- This is used as the nodes have the same name as the default ones
local S2 = minetest.get_translator("pk_core")

local S_nodes = minetest.get_translator(minetest.get_current_modname())

-----------------------
-- Local functions --
-----------------------

local function start_race_formspec(meta)
	local formspec = {
		"formspec_version[5]",
		"size[12,9]",
		"label[2.5,0.5;", minetest.formspec_escape(S_nodes("Set player positions before starting a race.")), "]",
		"field[0.375,1.2;5.25,0.8;player_one;" .. S_nodes("1st player position") .. ";${player1}]",
		"field[0.375,2.13;5.25,0.8;player_two;" .. S_nodes("2nd player position") .. ";${player2}]",
		"field[0.375,3;5.25,0.8;player_three;" .. S_nodes("3rd player position") .. ";${player3}]",
		"field[6,1.2;5.25,0.8;player_fourth;" .. S_nodes("4th player position") .. ";${player4}]",
		"field[6,2.13;5.25,0.8;player_fifth;" .. S_nodes("5th player position") .. ";${player5}]",
		"field[6,3;5.25,0.8;player_sixth;" .. S_nodes("6th player position") .. ";${player6}]",
		"field[0.375,5;5.25,0.8;player_seventh;" .. S_nodes("7th player position") .. ";${player7}]",
		"field[0.375,6;5.25,0.8;player_eighth;" .. S_nodes("8th player position") .. ";${player8}]",
		"field[0.375,7;5.25,0.8;player_nineth;" .. S_nodes("9th player position") .. ";${player9}]",
		"field[6,5;5.25,0.8;player_tenth;" .. S_nodes("10th player position") .. ";${player10}]",
		"field[6,6;5.25,0.8;player_eleventh;" .. S_nodes("11th player position") .. ";${player11}]",
		"field[6,7;5.25,0.8;player_twelveth;" .. S_nodes("12th player position") .. ";${player12}]",
		"button_exit[4,4.05;3,0.8;apply;" .. S_nodes("Apply changes") .. "]",
		"checkbox[0.375,8.5;use_meta;" .. S_nodes("Use metadata values") .. ";" .. meta:get_string("use_meta") .. "]",
	}

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Verifies if the players aren't in the same position.
--- This is used before starting a race.
--- @param player string the player that will be teleported to
--- @param meta string the metadata that will be checked
--- @param table table the table that will be used for the destination
--- @param position string the destination the player will be teleported to
--- @param use_meta boolean whether to use metadata values or not
local function player_position(player, meta, table, position, use_meta)
	local players = minetest.get_connected_players()

	for i = 1, #players - 1 do
		for j = i + 1, #players do
			-- Check if a player matches the same position as another player
			-- Thanks to rubenwardy and appgurueu for helping!
			if players[i]:get_pos() == players[j]:get_pos() then
				local position2 = table[math.random(#table)]
				if position2 == position then
					player_position(player, meta, table, position, use_meta)
				end
				minetest.after(0, function()
					if use_meta == true then
						player:move_to(minetest.string_to_pos(meta:get_string(position2)))
					else -- Useful when loading `player_positions.txt` rather than metadata values.
						player:move_to(minetest.string_to_pos(position2))
					end
				end)
				return
			end
		end
	end
end

--------------
-- Nodes --
--------------

minetest.register_node("pk_nodes:junglewood", {
	description = S("Jungle Wood Planks"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
})

-- We don't want to run the lobby on fire; thus, make it unflammable.
if minetest.get_modpath("wool") then
	minetest.override_item("wool:red", {
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
		flammable = 0, wool = 1, ["color_red"] = 1},
	})
end

-- Based off from `streets_solid_center_line_wide` node registration. Thanks!
minetest.register_node("pk_nodes:slow_down", {
	description = "Slows down an entity when on top",
	tiles = {"pk_nodes_invisible.png"},
	inventory_image = "default_cobble.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	pointable = false,
	buildable_to = false,
	drawtype = "nodebox",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, -0.499, 0.5 }
	},
	selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, -1 / 2 + 1 / 16, 1 / 2 }
	},
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.check_player_privs(placer, { core_admin = true }) or minetest.check_player_privs(placer, { builder = true }) then
			return minetest.item_place(itemstack, placer, pointed_thing)
		else
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
	end,
})

-- In case the user doesn't install the `mobs` mod, make an alias for the fence node.
-- Start: code taken from https://notabug.org/TenPlus1/mobs_redo/src/master/crafts.lua#L157-L171
if not minetest.get_modpath("mobs") then
	default.register_fence("pk_nodes:fence_wood", {
		description = minetest.get_translator("mobs")("Mob Fence"),
		texture = "default_wood.png",
		material = "default:fence_wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = minetest.get_modpath("default") and default.node_sound_wood_defaults(),
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 1.9, 0.5},
			}
		}
	})
	-- End: code taken from the `mobs_redo` mod
	minetest.register_alias("mobs:fence_wood", "pk_nodes:fence_wood")
	minetest.register_alias("special_nodes:fence_wood", "pk_nodes:fence_wood") 	-- Backwards compatibility
else
	minetest.register_alias("special_nodes:fence_wood", "pk_nodes:fence_wood") 	-- Backwards compatibility
	minetest.register_alias("pk_nodes:fence_wood", "mobs:fence_wood")
end

-- NOTES AND TO-DO'S:
-- 1. If the 1st block is being placed, insert it at the first line and so on with the other blocks.
-- 2. When deleting a block and adding the same block again, place it in the exact same line it was.
-- 3. If there's an empty line detected, use all the other positions except that one.
-- 4. (?) Use a database or another method to store the positions.
-- FOR MAP BUILDERS/TESTERS:
-- 1. If you remove one block, you will have to remove all the other ones to have them adjusted properly.
-- 2. Placing the same block in different positions will add the position to the list, but it may mess up.

for i = 1, 12, 1 do
	minetest.register_node("pk_nodes:player_" .. i .. "_position", {
		description = S_nodes("Player @1 position", i),
		tiles = {"streets_asphalt.png"},
		groups = { unbreakable = 1, not_in_creative_inventory = 1 },
		drop = "",
		on_place = function(itemstack, placer, pointed_thing)
			if minetest.check_player_privs(placer, { core_admin = true }) or minetest.check_player_privs(placer, { builder = true }) then
				minetest.log("action", "[PANQKART] Player " .. i .. " race position set to " .. minetest.pos_to_string(pointed_thing.above))

				-- Save the positions in a world-exclusive file which won't affect other worlds.
				local file,err = io.open(minetest.get_worldpath() .. "/player_positions.txt", "a+")
				if file then
					-- Check all lines and make sure the position isn't already saved.
					for line in file:lines() do
						if line == minetest.pos_to_string(pointed_thing.above) then
							file:close()
							return minetest.item_place(itemstack, placer, pointed_thing)
						end
					end
					file:write(minetest.pos_to_string(pointed_thing.above) .. "\n")
					file:close()
				else
					minetest.log("error", "[PANQKART] Error while saving player " .. i .. " positions: " .. err)
				end

				return minetest.item_place(itemstack, placer, pointed_thing)
			end

			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("player" .. tostring(i), minetest.pos_to_string(pos))
		end,
		can_dig = function(pos, player)
			if minetest.check_player_privs(player, { core_admin = true }) or minetest.check_player_privs(player, { builder = true }) then
				return default.can_interact_with_node(player, pos)
			end

			minetest.chat_send_player(player:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return false
		end,
		on_dig = function(pos, node, digger)
			local meta = minetest.get_meta(pos)
			local file,err = io.open(minetest.get_worldpath() .. "/player_positions.txt", "r")

			if file then
				-- Check all lines. If position is saved, remove it from the list.
				local fileContent = {}
				for line in file:lines() do
					table.insert(fileContent, line)
				end

				fileContent[i] = ""
				file = io.open(minetest.get_worldpath() .. "/player_positions.txt", "w")
				for _, value in ipairs(fileContent) do
					if value ~= meta:get_string("player" .. i) then
						file:write(value .. "\n")
					end
				end
				file:close()
			else
				minetest.log("error", "[PANQKART] Error while reading player positions: " .. err)
			end
			return minetest.node_dig(pos, node, digger)
		end,
	})
	-- Backwards compatibility
	minetest.register_alias("special_nodes:player_" .. i .. "_position", "pk_nodes:player_" .. i .. "_position")
end

minetest.register_lbm({
	label = "Race positions",
	name = "pk_nodes:race_positions",

	nodenames = {
		"pk_nodes:player_1_position",
		"pk_nodes:player_2_position",
		"pk_nodes:player_3_position",
		"pk_nodes:player_4_position",
		"pk_nodes:player_5_position",
		"pk_nodes:player_6_position",
		"pk_nodes:player_7_position",
		"pk_nodes:player_8_position",
		"pk_nodes:player_9_position",
		"pk_nodes:player_10_position",
		"pk_nodes:player_11_position",
		"pk_nodes:player_12_position"
	},
	run_at_every_load = true,

	action = function(pos, node)
		-- Save the positions in a world-exclusive file which won't affect other worlds.
		local file,err = io.open(minetest.get_worldpath() .. "/player_positions.txt", "a+")
		if file then
			for line in file:lines() do
				if line == minetest.pos_to_string(pos) then
					file:close()
					return
				end
			end
			file:write(minetest.pos_to_string(pos) .. "\n")
			file:close()
		else
			minetest.log("error", "[PANQKART] Error while saving player positions: " .. err)
		end
	end,
})

minetest.register_node("pk_nodes:start_race", {
	description = S_nodes("Start a race!"),
	tiles = {"default_mossycobble.png"},
	drop = "",
	light_source = 7,
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if minetest.check_player_privs(clicker, { core_admin = true }) then
			meta:set_string("formspec", start_race_formspec(meta))
		else
			meta:set_string("formspec", "")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", start_race_formspec(meta))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		-- TODO: load player positions from `.txt` file
		local strings = {
			"player1",
			"player2",
			"player3",
			"player4",
			"player5",
			"player6",
			"player7",
			"player8",
			"player9",
			"player10",
			"player11",
			"player12",
		}

		local field = {
			fields.player_one,
			fields.player_two,
			fields.player_three,
			fields.player_fourth,
			fields.player_fifth,
			fields.player_sixth,
			fields.player_seventh,
			fields.player_eighth,
			fields.player_nineth,
			fields.player_tenth,
			fields.player_eleventh,
			fields.player_twelveth,
		}

		local meta = minetest.get_meta(pos)
		if fields.use_meta then
			if meta:get_string("use_meta") == "false" then
				meta:set_string("use_meta", "true")
			else
				meta:set_string("use_meta", "false")
			end
		end

		if fields.apply then
			-- Set `true` or `false` depending on the checkbox status.
			for _,number in ipairs(field) do
				if number == "0" then
					minetest.chat_send_player(sender:get_player_name(), S_nodes("Please specify a valid value different than zero."))
					return
				end
			end
			for i,player_name in ipairs(strings) do
				local old_field = meta:get_string(player_name)
				if minetest.string_to_pos(field[i]) then
					meta:set_string(player_name, field[i])
					if i == 1 and old_field ~= meta:get_string(player_name) then
						minetest.chat_send_player(sender:get_player_name(), S_nodes("Successfully updated the @1st field!\n", i))
					elseif i == 2 and old_field ~= meta:get_string(player_name) then
						minetest.chat_send_player(sender:get_player_name(), S_nodes("Successfully updated the @1nd field!\n", i))
					elseif i == 3 and old_field ~= meta:get_string(player_name) then
						minetest.chat_send_player(sender:get_player_name(), S_nodes("Successfully updated the @1rd field!\n", i))
					elseif i >= 4 and old_field ~= meta:get_string(player_name) then
						minetest.chat_send_player(sender:get_player_name(), S_nodes("Successfully updated the @1th field!\n", i))
					end
				elseif field[i] == "" then
					meta:set_string(player_name, field[i])
				-- Tell the user the current position is invalid
				else
					minetest.chat_send_player(sender:get_player_name(), "\n" .. S_nodes("Certain fields are not a valid Minetest position. These will not be updated. Use: <x,y,z>"))
					break
				end
			end

			meta:set_string("formspec", start_race_formspec(meta))
		end
	end,
	can_dig = function(pos, player)
		local strings = {
			"player1",
			"player2",
			"player3",
			"player4",
			"player5",
			"player6",
			"player7",
			"player8",
			"player9",
			"player10",
			"player11",
			"player12",
		}
		local meta = minetest.get_meta(pos)
		for _,player_number in ipairs(strings) do
			if meta:get_string(player_number) ~= "" then return end
		end
		return default.can_interact_with_node(player, pos)
	end,
})

-- Let us handle the player positions the user just set above
minetest.register_globalstep(function(dtime)
	local strings = {
		"player1",
		"player2",
		"player3",
		"player4",
		"player5",
		"player6",
		"player7",
		"player8",
		"player9",
		"player10",
		"player11",
		"player12",
	}

	-- Used to place the player in a random position
	local position = strings[math.random(#strings)]

	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local node = minetest.get_node(vector.subtract(pos, vector.new(0, 0.5, 0)))

		if node.name == "pk_nodes:start_race" and not core_game.ran_once[player] == true then
			local meta = minetest.get_meta(vector.new(pos.x, pos.y - 0.5, pos.z))

			-- Loading positions from `.txt` file
			local fileContent = {}
			local file,err = io.open(minetest.get_worldpath() .. "/player_positions.txt", "r")

			if file and meta:get_string("use_meta") ~= "true" then
				for line in file:lines() do
					table.insert(fileContent, line)
				end

				local line_position = fileContent[math.random(#fileContent)]
				if minetest.string_to_pos(line_position) then
					player:move_to(minetest.string_to_pos(line_position))
					player_position(player, meta, strings, line_position, false) -- Make sure positions are not repeated.
				else
					-- TODO: add translations
					minetest.chat_send_player(player:get_player_name(), "One or more positions are invalid. Cannot start race. Aborting.")
					minetest.chat_send_player(player:get_player_name(), "If you think this is a mistake, please report it on the official's PanqKart Discord server or contact the server administrator.")
					return
				end

				-- The player will be teleported inside the node, thus, teleport them a bit higher.
				player:set_pos(vector.new(player:get_pos().x, player:get_pos().y + 1, player:get_pos().z))
			else
				if not file then
					minetest.log("error", "[PANQKART] Error while reading player positions: " .. err .. ". Configured/metadata positions will be used instead.")
				end

				player:move_to(minetest.string_to_pos(meta:get_string(position)))
				player_position(player, meta, strings, position, true) -- Make sure positions are not repeated.
			end

			for _,string in ipairs(strings) do -- luacheck: ignore
				if core_game.ran_once[player] == true then break end
				if minetest.string_to_pos(meta:get_string(string)) then

					core_game.reset_values(player) -- Reset values in case something was stored
					core_game.start_game(player)
					core_game.ran_once[player] = true

					-- Checkpoint system initialization.
					pk_checkpoints.player_lap_count[player] = 1 -- Should always start at 1
					pk_checkpoints.player_checkpoint_count[player] = 1 -- This is to check the checkpoint node number.
					pk_checkpoints.player_checkpoint_distance[player] = 0
					pk_checkpoints.can_win[player] = false

					return
				else
					minetest.chat_send_player(player:get_player_name(), "One or more positionss are invalid. Cannot start race. Aborting.")
					minetest.chat_send_player(player:get_player_name(), "If you think this is a mistake, please report it on the official's PanqKart Discord server or contact the server administrator.")

					core_game.ran_once[player] = true
					minetest.after(10, function() core_game.ran_once[player] = false end)
					break
				end
			end
		end
	end
end)

minetest.register_node("pk_nodes:spawn_node", {
	description = S_nodes("Spawn node. Do not place multiple nodes."),
	tiles = {},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)

		-- DEPRECATED. Will be removed in future versions.
		minetest.settings:set("lobby_position", minetest.pos_to_string(pos)) -- Changed so we can access this value later.
		meta:set_string("lobby_position", minetest.pos_to_string(pos))
	end,
})

minetest.register_node("pk_nodes:tp_lobby", {
	description = S_nodes("Teleport back to lobby node."),
	tiles = {"default_coral_brown.png"},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	is_ground_content = false,
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("pk_nodes:asphalt", {
	description = S("Asphalt node. Used for ending blocks."),
	tiles = {"streets_asphalt.png"},
	drop = "",
	groups = {unbreakable = 1, asphalt = 1},
	paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("pk_nodes:lava_node", {
	description = S("Teleport back to a few nodes when an entity touches it."),
	tiles = {"default_stone.png"},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	is_ground_content = false,
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

-- Backward compatibility aliases
minetest.register_alias("special_nodes:start_race", "pk_nodes:start_race")
minetest.register_alias("special_nodes:slow_down", "pk_nodes:slow_down")
minetest.register_alias("special_nodes:spawn_node", "pk_nodes:spawn_node")
minetest.register_alias("special_nodes:tp_lobby", "pk_nodes:tp_lobby")
minetest.register_alias("special_nodes:asphalt", "pk_nodes:asphalt")
minetest.register_alias("special_nodes:lava_node", "pk_nodes:lava_node")
minetest.register_alias("special_nodes:junglewood", "pk_nodes:junglewood")
minetest.register_alias("special_nodes:asphalt", "pk_nodes:asphalt")
