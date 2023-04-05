--[[
All PanqKart Minetest commands.

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

--[[minetest.register_chatcommand("change_position", {
	params = "<x y z>",
	description = S("Change the lobby's position"),
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- Start: code taken from Minetest builtin teleport command
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if not p.x and not p.y and not p.z then
			return false, S("Wrong usage of the command. Use <x y z>")
		end
		-- End: code taken from Minetest builtin teleport command
		core_game.position = vector.new(p.x, p.y, p.z)
		return true, S("Changed the lobby's position to: <@1>", param)
    end,
})--]]

if minetest.get_modpath("pk_shop") then
	-- Reset coins command
	minetest.register_chatcommand("reset_coins", {
		params = "<player>",
		description = S("Reset all coins to 0 to the given player"),
		privs = {
			core_admin = true,
		},
		func = function(name, param)
			if param == "" then
				return false, S("Invalid arguments. See /help reset_coins")
			end

			if not minetest.get_auth_handler().get_auth(param) then
				return false, S("Player @1 does not exist.", param)
			end

			local player = minetest.get_player_by_name(param)

			local meta = player:get_meta()
			local coins = minetest.deserialize(meta:get_string("player_coins"))

			if coins and coins.bronze_coins and coins.bronze_coins ~= 0 then
				minetest.chat_send_player(name, S("Successfully resetted bronze coins to @1", param))

				coins.bronze_coins = 0
				meta:set_string("player_coins", minetest.serialize(coins))
			else
				minetest.chat_send_player(name, S("@1 has no bronze coins yet.", param))
			end
			if coins and coins.silver_coins and coins.silver_coins ~= 0 then
				minetest.chat_send_player(name, S("Successfully resetted silver coins to @1", param))

				coins.silver_coins = 0
				meta:set_string("player_coins", minetest.serialize(coins))
			else
				minetest.chat_send_player(name, S("@1 has no silver coins yet.", param))
			end
			if coins and coins.gold_coins and coins.gold_coins ~= 0 then
				minetest.chat_send_player(name, S("Successfully resetted gold coins to @1", param))

				coins.gold_coins = 0
				meta:set_string("player_coins", minetest.serialize(coins))
			else
				minetest.chat_send_player(name, S("@1 has no gold coins yet.", param))
			end
		end,
	})

	-- Reset upgrades command
	minetest.register_chatcommand("reset_upgrades", {
		params = "<player>",
		description = S("Resets all car upgrades (including Hovercraft) to the given player."),
		privs = {
			core_admin = true
		},
		func = function(name, param)
			if param == "" then
				return false, S("Invalid arguments. See /help reset_upgrades")
			end

			if not core.get_auth_handler().get_auth(param) then
				return false, S("Player @1 does not exist.", param)
			end

			local player = minetest.get_player_by_name(param)

			if not player then
				return false, S("Player @1 is not online.", param)
			end

			local meta = player:get_meta()

			local car01_speed = minetest.deserialize(meta:get_string("speed"))
			local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))

			if not car01_speed and not hover_speed then
				return false, S("Player @1 doesn't have any updates yet.", param)
			elseif car01_speed then
				car01_speed.reverse_speed = vehicle_mash.car01_def.max_speed_reverse
				car01_speed.forward_speed = vehicle_mash.car01_def.max_speed_forward
				car01_speed.turn_speed = vehicle_mash.car01_def.turn_speed
				car01_speed.accel = vehicle_mash.car01_def.accel

				meta:set_string("speed", "")

				minetest.chat_send_player(name, S("Successfully set CAR01 reverse/forward speed to default to @1.", param))
			elseif hover_speed then
				hover_speed.reverse_speed = vehicle_mash.hover_def.max_speed_reverse
				hover_speed.forward_speed = vehicle_mash.hover_def.max_speed_forward
				hover_speed.turn_speed = vehicle_mash.hover_def.turn_speed
				hover_speed.accel = vehicle_mash.hover_def.accel

				meta:set_string("hover_speed", "")

				minetest.chat_send_player(name, S("Successfully set Hovercraft reverse/forward speed to default to @1.", param))
			end
		end,
	})

    -- TODO: add commands to add/remove specific coins and upgrades.
end

--- @brief A function to show a donation formspec
--- to the specified player(s), with donation links and perks.
--- @param name string the player that will be used to show the formspec to
--- @returns the formspec table
local function donate_formspec(name)
    local formspec = {
        "formspec_version[5]",
        "size[10,11]",
        "label[0.375,0.5;", minetest.formspec_escape("Thanks for your interest! When donating, you will get\nin-game perks, a shoutout, a special role, and more!"), "]",
		"label[0.375,1.75;", minetest.formspec_escape("No matter how many amount you donate to us, you will get:"), "]",
		"label[1.80,1.75;", minetest.formspec_escape("\n\nDouble coins\nA yellow nametag with a premium tag\nEarly access to new features\nVIP house to hang out with other VIP members\n\nPrioritized feature requests,\nbug reports, map suggestions\n\nSocial media shoutout (optional)\nSpecial Discord role to stand out"), "]",
		"label[0.375,8;", minetest.formspec_escape("You can choose your favorite platform to donate us:\nliberapay.com/Panquesito7 or github.com/sponsors/Panquesito7"), "]",
		"label[0.375,9.25;", minetest.formspec_escape("Contact Panquesito7 to claim your rewards, via DM, e-mail\n(halfpacho@gmail.com), or via Discord: Panquesito7#3723"), "]",
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

minetest.register_chatcommand("donate", {
	params = "<player>",
	description = S("Shows additional information when donating and links for the same."),
    privs = {
        shout = true,
    },
    func = function(name, param)
		if param == "" then
			minetest.show_formspec(name, "pk_core:donate", donate_formspec(name))
			return
		end

		if param ~= "" and
				minetest.check_player_privs(name, { ban = true }) or param == name then
			name = param
		else
			return false, S("You don't have sufficient permissions to run this command. Missing privileges: ban")
		end

		local player = minetest.get_player_by_name(name)
		if player then
			minetest.show_formspec(param, "pk_core:donate", donate_formspec(param))
			return true, S("Donation formspec shown to @1.", param)
		else
			return false, S("Player @1 does not exist or is not online.", param)
		end
	end,
})
