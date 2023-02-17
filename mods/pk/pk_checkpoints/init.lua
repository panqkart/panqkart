--[[
	Checkpoint system for the use of multiple laps
	Copyright (C) 2023 David Leal

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

pk_checkpoints = {
    player_lap_count = { },
    player_checkpoint_count = { },
}

local S = minetest.get_translator(minetest.get_current_modname())
local S2 = minetest.get_translator("pk_core") or S

minetest.register_node("pk_checkpoints:checkpoint", {
    description = S("Checkpoint. Do NOT place unless you know what you're doing."),
    tiles = { "pk_nodes_invisible.png" },
    groups = { not_in_creative_inventory = 1, unbreakable = 1 },
    paramtype2 = "facedir",
    drawtype = "nodebox",
    pointable = false,
    node_box = {
        type = "fixed",
        fixed = {
            { -1.45, -0.5, -1.45, 1.45, 0, 1.45 },
        },
    },
    on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
    can_dig = function(pos, player)
        if not minetest.check_player_privs(player, { core_admin = true }) then
            minetest.chat_send_player(player:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
            return false
        end
        return true
    end,
})
