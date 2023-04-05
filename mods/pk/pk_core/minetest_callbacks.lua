--[[
Minetest function callbacks such as `on_joinplayer`.

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

local S = core_game.S

minetest.register_on_joinplayer(function(player)
	-- Set shadows only if the game's running on Minetest 5.6.0 and above.
	if player:get_lighting().shadows ~= nil then
		player:set_lighting({ shadows = { intensity = 0.33 } })
	end

	core_game.spawn_initialize(player, 0.2)
	core_game.nametags(player:get_player_name())
end)

minetest.register_on_respawnplayer(function(player)
	core_game.spawn_initialize(player, 0.1)
	minetest.log("action", "[PANQKART] Player " .. player:get_player_name() .. " died. Teleported to the lobby successfully.")
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_all(S("@1 just joined PanqKart. Give them a warm welcome to our community!", player:get_player_name()))
end)

minetest.register_on_leaveplayer(function(player)
	-- Reset all values to prevent crashes.
	core_game.reset_values(player)

	if core_game.game_started == true then
		local attached_to = player:get_attach()
		if attached_to then
			local entity = attached_to:get_luaentity()

			if entity then
				lib_mount.detach(player, vector.new(0,0,0))
				entity.object:remove()
			end
		end

		-- Is the player the last player to win? If so, end the race immediately.
		for _,name in pairs(core_game.players_on_race) do
			if #core_game.players_on_race == #core_game.players_that_won then
				return -- Do nothing. This means all the players have won already.
			end

			core_game.race_end()
		end

		-- Have all the players on a race left, or the current players are lower than the minimum players?
		if #core_game.players_on_race == 0 or core_game.player_count == 0 or
			core_game.player_count < tonumber(minetest.settings:get("minimum_required_players")) or
			#core_game.players_on_race < tonumber(minetest.settings:get("minimum_required_players")) then
			-- Remove the waiting to end HUD for all players (if applicable).
			for _,player_name in ipairs(minetest.get_connected_players()) do
				core_game.is_waiting_end[player_name] = false
				hud_fs.close_hud(player_name, "pk_core:pending_race")
			end

			-- Cleanup racing and checkpoint data.
			pk_checkpoints.cleanup()
			core_game.race_end(false)
		end
	end
end)

-- Keep players protected
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	minetest.after(0, function() player:set_hp(player:get_hp() + damage) end)
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if hp_change < 0 then
		minetest.after(0, function() player:set_hp(player:get_hp() - hp_change) end)
	end
end)
