--[[
Adds nodes that look like other nodes (or just new ones) with different functionalities.

Copyright (C) 2022 David Leal (halfpacho@gmail.com)
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
local S2 = minetest.get_translator("core_game")

-----------------------
-- Local functions --
-----------------------

local function start_race_formspec()
	local text = "Set player positions before starting a race."
	local formspec = {
		"formspec_version[4]",
		"size[12,8]",
		"label[2.5,0.5;", minetest.formspec_escape(text), "]",
		"field[0.375,1.2;5.25,0.8;player_one;1st player position;${player1}]",
		"field[0.375,2.13;5.25,0.8;player_two;2nd player position;${player2}]",
		"field[0.375,3;5.25,0.8;player_three;3rd player position;${player3}]",
		"field[6,1.2;5.25,0.8;player_fourth;4th player position;${player4}]",
		"field[6,2.13;5.25,0.8;player_fifth;5th player position;${player5}]",
		"field[6,3;5.25,0.8;player_sixth;6th player position;${player6}]",
		"field[0.375,5;5.25,0.8;player_seventh;7th player position;${player7}]",
		"field[0.375,6;5.25,0.8;player_eighth;8th player position;${player8}]",
		"field[0.375,7;5.25,0.8;player_nineth;9th player position;${player9}]",
		"field[6,5;5.25,0.8;player_tenth;10th player position;${player10}]",
		"field[6,6;5.25,0.8;player_eleventh;11th player position;${player11}]",
		"field[6,7;5.25,0.8;player_twelveth;12th player position;${player12}]",
		"button_exit[4,4.05;3,0.8;apply;Apply changes]",
	}

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--------------
-- Nodes --
--------------

minetest.register_node("special_nodes:junglewood", {
	description = S("Jungle Wood Planks"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
})

minetest.register_node("special_nodes:start_race", {
	description = S2("Start a race!"),
	tiles = {"default_mossycobble.png"},
	drop = "",
	light_source = 7,
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if minetest.check_player_privs(clicker, { core_admin = true }) then
			meta:set_string("formspec", start_race_formspec())
		else
			meta:set_string("formspec", "")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", start_race_formspec())
	end,
	on_receive_fields = function(pos, formname, fields, sender)
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
		if fields.apply then
			for _,number in ipairs(field) do
				if number == "0" then
					minetest.chat_send_player(sender:get_player_name(), "Please specify a valid value different than zero.")
					return
				end
			end
			for i,player_name in ipairs(strings) do
				if minetest.string_to_pos(field[i]) then
					meta:set_string(player_name, field[i])
				else
					minetest.chat_send_player(sender:get_player_name(), "Please set ALL positions and use only a valid Minetest position. Use: <x,y,z>")
					return
				end
			end

			minetest.chat_send_player(sender:get_player_name(), "Successfully updated player positions!")
			meta:set_string("formspec", start_race_formspec())
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
		local node = minetest.get_node(vector.subtract(pos, {x=0,y=0.5,z=0}))

		if node.name == "special_nodes:start_race" and not core_game.ran_once[player] == true then
			local meta = minetest.get_meta({x = pos.x, y = pos.y - 0.1, z = pos.z})
			for _,string in ipairs(strings) do
				if core_game.ran_once[player] == true then break end
				if not minetest.string_to_pos(meta:get_string(string)) then
					minetest.chat_send_player(player:get_player_name(), "Positions haven't been set. Cannot start race. Aborting.")
					minetest.chat_send_player(player:get_player_name(), "If you think this is a mistake, please report it on the official's PanqKart Discord server or contact the server administrator.")

					core_game.ran_once[player] = true
					minetest.after(20, function() core_game.ran_once[player] = false end)
					return
				else
					player:move_to(minetest.string_to_pos(meta:get_string(position)))

					core_game.reset_values(player) -- Reset values in case something was stored
					core_game.start_game(player)
					core_game.ran_once[player] = true
				end
			end
		end
	end
end)

minetest.register_node("special_nodes:spawn_node", {
	description = "Spawn node. Do not place multiple nodes.",
	tiles = {},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)

		minetest.settings:set("lobby_position", minetest.pos_to_string(pos)) -- Changed so we can access this value later.
		meta:set_string("lobby_position", minetest.pos_to_string(pos))
	end,
})

minetest.register_node("special_nodes:tp_lobby", {
	description = "Teleport back to lobby node.",
	tiles = {"default_coral_brown.png"},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	is_ground_content = false,
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("special_nodes:asphalt", {
	description = "Asphalt node. Used for ending blocks.",
	tiles = {"streets_asphalt.png"},
	drop = "",
	groups = {unbreakable = 1, asphalt = 1},
	paramtype = "light",
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_node("special_nodes:lava_node", {
	description = "Teleport back a few nodes when a car touches it.",
	tiles = {"default_coral_brown.png"},
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	is_ground_content = false,
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_alias("core_game:junglenoob", "special_nodes:junglewood") -- Backwards compatibility (this used to be the old node name lol)
