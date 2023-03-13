--[[
All privilege management functions.

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

--- @brief Give customized nametags for those
--- who have the premium or core administrator role on grant/revoke.
--- @param name string the player to update the nametag to
--- @returns nil
function core_game.nametags(name)
	local player = minetest.get_player_by_name(name)
	if not player then return end

	-- Administrators
	minetest.after(0, function()
		if minetest.check_player_privs(player:get_player_name(), { core_admin = true } ) then
			player:set_nametag_attributes({
				text = "[STAFF] " .. player:get_player_name(),
				color = {r = 255, g = 0, b = 0},
				bgcolor = false
			})
			player:set_properties({zoom_fov = 15}) -- Let administrators use zoom
			return
		else
			player:set_nametag_attributes({
				text = player:get_player_name(),
				color = {r = 255, g = 255, b = 255},
				bgcolor = false
			})
			player:set_properties({zoom_fov = 0}) -- Remove zoom to normal players
		end

		-- VIP/Premium users
		if minetest.get_modpath("pk_premium") and minetest.check_player_privs(player:get_player_name(), { has_premium = true } ) then
			player:set_nametag_attributes({
				text = "[VIP] " .. player:get_player_name(),
				color = {r = 255, g = 255, b = 0},
				bgcolor = false
			})
			return
		else
			player:set_nametag_attributes({
				text = player:get_player_name(),
				color = {r = 255, g = 255, b = 255},
				bgcolor = false
			})
		end
	end)
end

minetest.register_privilege("core_admin", {
    description = S("Can manage the lobby position and core game configurations."),
    give_to_singleplayer = true,
	give_to_admin = true,

	on_grant = core_game.nametags,
	on_revoke = core_game.nametags,
})
