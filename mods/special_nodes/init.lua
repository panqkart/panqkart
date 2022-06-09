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

--------------
-- Nodes --
--------------

local S = minetest.get_translator("default") -- This is used as the nodes have the same name as the default ones
local S2 = minetest.get_translator("core_game")

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
})

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

minetest.register_alias("core_game:junglenoob", "special_nodes:junglewood") -- Backwards compatibility (this used to be the old node name lol)
