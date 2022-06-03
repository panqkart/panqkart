--[[
Includes the core premium features for the PanqKart game.

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

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

if minetest.settings:get_bool("enable_premium_features") == nil then
	minetest.settings:set_bool("enable_premium_features", true) -- Enable premium features by default if no value initialized
elseif minetest.settings:get_bool("enable_premium_features") == false then
	minetest.log("action", "[RACING GAME] Premium features are disabled. Not initializing.")
	return
end

local house_location = { x = -89.6, y = 71.5, z = 187.2 }

------------------
-- Privileges --
------------------
minetest.register_privilege("has_premium", {
    description = S("The user has premium features. See /donate for more information."),
    give_to_singleplayer = false,
    give_to_admin = false,
	on_grant = core_game.grant_revoke,
	on_revoke = core_game.grant_revoke,
})

----------------
-- Commands --
----------------

minetest.register_chatcommand("premium_house", {
	params = "<player>",
	description = S("Teleport (the given player) to the premium/VIP house."),
    privs = {
        shout = true,
    },
    func = function(name, param)
		if param == "" then
			if not minetest.check_player_privs(minetest.get_player_by_name(name), { has_premium = true }) then
				return false, S("You don't have sufficient permissions to run this command. Missing privileges: has_premium")
			else
				minetest.get_player_by_name(name):set_pos(house_location)
				return true, S("Successfully teleported to the premium/VIP house.")
			end
		end

		if param ~= "" and
				minetest.check_player_privs(name, { core_admin = true }) or param == name then
			name = param
		else
			return false, S("You don't have sufficient permissions to run this command. Missing privileges: core_admin")
		end

		local player = minetest.get_player_by_name(name)
		if player then
			player:set_pos(house_location)
			return true, S("Successfully teleported @1 to the premium/VIP house.", param)
		else
			return false, S("Player @1 does not exist or is not online.", name)
		end
	end,
})
