--[[
Lobby/map generation and configurations.

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

if minetest.setting_get_pos("lobby_position") then
    core_game.position = minetest.setting_get_pos("lobby_position")
end

if minetest.get_modpath("pk_nodes") then
	minetest.register_lbm({
		label = "Lobby/spawn node position",
		name = "pk_core:lobby_position",

		nodenames = {"pk_nodes:spawn_node"},
		run_at_every_load = true,

		action = function(pos, node)
			core_game.position = pos
			minetest.settings:set("lobby_position", minetest.pos_to_string(pos)) -- DEPRECATED. Will be removed in future versions.

			-- Save lobby position to file. World-exclusive which won't affect other worlds.
			local file,err = io.open(minetest.get_worldpath() .. "/lobby_position.txt", "w+")
			if file then
				file:write(tostring(pos))
				file:close()
			else
				minetest.log("error", "[PANQKART] Error while saving lobby position: " .. err)
			end
		end,
	})
end
