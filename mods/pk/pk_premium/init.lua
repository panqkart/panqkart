--[[
Includes the core premium features for the PanqKart game.

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

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

if minetest.settings:get_bool("enable_premium_features") == nil then
	minetest.settings:set_bool("enable_premium_features", true) -- Enable premium features by default if no value initialized
elseif minetest.settings:get_bool("enable_premium_features") == false then
	minetest.log("action", "[PANQKART] Premium features are disabled. Not initializing.")
	return
end

local house_location

if minetest.setting_get_pos("premium_position") then
	house_location = minetest.setting_get_pos("premium_position")
else
	house_location = { }
end

------------------
-- Privileges --
------------------
minetest.register_privilege("has_premium", {
    description = S("The user has premium features. See /donate for more information."),
    give_to_singleplayer = false,
    give_to_admin = false,

	on_grant = core_game.nametags,
	on_revoke = core_game.nametags,
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
			elseif minetest.check_player_privs(minetest.get_player_by_name(name), { has_premium = true }) and house_location.x then
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
		if player and house_location.x then
			player:set_pos(house_location)
			return true, S("Successfully teleported @1 to the premium/VIP house.", param)
		else
			return false, S("Player @1 does not exist, not online, or the specified position is invalid.", name)
		end
	end,
})

minetest.register_chatcommand("premium_location", {
	params = "<x y z>",
	description = S("Change the premium's house location."),
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- Set the location to the current player position
		if param == "" then
			local player = minetest.get_player_by_name(name)
			if player then
				house_location = player:get_pos()
				minetest.settings:set("premium_position", minetest.pos_to_string(house_location))
				return true, S("Successfully set the premium house location to your current position.")
			else
				return false, S("Player @1 does not exist or is not online.", name)
			end
		end

		-- Start: code taken from Minetest builtin teleport command
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if not p.x and not p.y and not p.z then
			return false, S("Wrong usage of command. Use <x y z>")
		end
		-- End: code taken from Minetest builtin teleport command
		house_location = vector.new(p.x, p.y, p.z)
		minetest.settings:set("premium_position", minetest.pos_to_string(house_location))

		return true, S("Successfully changed premium's house location to: <@1>", param)
    end,
})
