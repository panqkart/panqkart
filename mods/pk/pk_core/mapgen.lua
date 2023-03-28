--[[
Lobby/map generation and configurations.

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

if minetest.setting_get_pos("lobby_position") then
    core_game.position = minetest.setting_get_pos("lobby_position")
end

if minetest.get_modpath("pk_nodes") then
	minetest.register_lbm({
		label = "Lobby/spawn node position",
		name = "pk_core:lobby_position",

		nodenames = { "pk_nodes:spawn_node" },
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

--- @brief The core function to initialize the spawnpoint
--- and place the player on the spawnpoint.
--- @details The function will check for:
--- 1. A world-exclusive file that saves the lobby position.
--- 2. A value in the Minetest settings (DEPRECATED).
--- 3. Global variable that was updated each time the `spawn_node` node was detected (DEPRECATED).
--- If none of these are found/valid, it will use a fallback position, or the current player's position.
--- @param player userdata the player that will be teleported to the lobby
--- @param time number the time in seconds that the player will be teleported to the lobby
--- @return nil
function core_game.spawn_initialize(player, time)
	minetest.after(time, function()
		local position, value

		-- Read spawnpoint from world-exclusive file which won't affect other worlds.
		local file,err = io.open(minetest.get_worldpath() .. "/lobby_position.txt", "r")
		if file then
			value = tostring(file:read("*a"))
			file:close()
		else
			minetest.log("error", "[PANQKART] Error while loading lobby position: " .. err .. ". Deprecated/fallback settings will be used.")
		end

		-- DEPRECATED CALLBACKS. Will be removed in future versions.
		if not minetest.string_to_pos(value) then
			if not minetest.setting_get_pos("lobby_position") and not (core_game.position and core_game.position.x) then -- Both setting/variable are nil
				position = player:get_pos()														-- To prevent crashes
			elseif minetest.setting_get_pos("lobby_position") and not (core_game.position and core_game.position.x) then -- Setting is there, however, variable isn't
				position = minetest.setting_get_pos("lobby_position")
			elseif core_game.position and core_game.position.x then													-- Position is set in the variable
				position = core_game.position
			else																				-- Fallback
				position = player:get_pos()
				minetest.log("warning", "[PANQKART] No spawnpoint found. Using fallback position/settings.")
			end
		elseif minetest.string_to_pos(value) then 												-- Position is set in the file
			position = minetest.string_to_pos(value)
		else																				    -- Fallback (2nd check)
			position = player:get_pos()
			minetest.log("warning", "[PANQKART] No spawnpoint found. Using fallback position/settings.")
		end
		local meta = minetest.get_meta(position)

		-- Let's use the position of the `spawn_node` node. This is very useful
		-- when placing the lobby schematic and not the node itself.
		if meta and minetest.string_to_pos(meta:get_string("lobby_position")) then
			player:set_pos(minetest.string_to_pos(meta:get_string("lobby_position")))
			minetest.log("action", "[PANQKART] `spawn_node` node position was used for player " .. player:get_player_name() .. ". Successfully teleported.")
		else
			-- If not found, use the default position defined in settings
			player:set_pos(position)
			minetest.log("action", "[PANQKART] Teleported " .. player:get_player_name() .. " to the settings spawnpoint")
		end
	end)
	minetest.log("action", "[PANQKART] Player " .. player:get_player_name() .. " joined and was teleported to the lobby successfully.")
end
