--[[
Minetest function callbacks such as `on_joinplayer`.

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

local S = core_game.S

minetest.register_on_joinplayer(function(player)
	player:set_lighting({ shadows = { intensity = 0.33 } })
	core_game.spawn_initialize(player, 0.2)

	-- VIP/Premium users
	if minetest.get_modpath("premium") and minetest.check_player_privs(player, { has_premium = true } ) then
		player:set_nametag_attributes({
			text = "[VIP] " .. player:get_player_name(),
			color = {r = 255, g = 255, b = 0},
			bgcolor = false
		})
	end

	-- Administrators
	if minetest.check_player_privs(player, { core_admin = true } ) then
		player:set_nametag_attributes({
			text = "[STAFF] " .. player:get_player_name(),
			color = {r = 255, g = 0, b = 0},
			bgcolor = false
		})
		player:set_properties({zoom_fov = 15}) -- Let administrators zoom
	end
end)

minetest.register_on_respawnplayer(function(player)
	player:set_pos(core_game.position)
	minetest.log("action", "[PANQKART] Player " .. player:get_player_name() .. " died. Teleported to the lobby successfully.")
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_all(S("@1 just joined PanqKart. Give them a warm welcome to our community!", player:get_player_name()))
end)

minetest.register_on_leaveplayer(function(player)
	-- Reset all values to prevent crashes
	core_game.reset_values(player)

	if core_game.game_started == true then
		local attached_to = player:get_attach()
		if attached_to then
			local entity = attached_to:get_luaentity()

			if entity then
				lib_mount.detach(player, {x=0, y=0, z=0})
				entity.object:remove()
			end
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
