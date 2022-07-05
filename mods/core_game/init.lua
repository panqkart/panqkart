--[[
Includes everything to make racing work right, such as player counting, scoreboard, lobby position, and more.

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

core_game = { }

if tonumber(minetest.settings:get("minimum_required_players")) == nil then
	minetest.settings:set("minimum_required_players", 4) -- SET MINIMUM REQUIRED PLAYERS FOR A RACE
elseif tonumber(minetest.settings:get("minimum_required_players")) > 12 then
	error("The minimum required players cannot be over 12 players. Please specify a number between 1-12. Contact us if you need any help.", 1)
end

assert(
	minetest.get_mapgen_setting("mg_name") == "singlenode",
	"In order to play PanqKart, you must set your mapgen to 'singlenode'. If you need any help, don't hesitate to contact us via our Discord."
)

core_game.players_on_race = { } -- Save players on the current race in a vector
core_game.level_position = { } -- EDIT TO YOUR NEEDS

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

if minetest.setting_get_pos("lobby_position") then
    core_game.position = minetest.setting_get_pos("lobby_position")
end

minetest.register_lbm({
	label = "Lobby/spawn node position",
	name = "core_game:lobby_position",

	nodenames = {"special_nodes:spawn_node"},
	run_at_every_load = true,

	action = function(pos, node)
		if minetest.setting_get_pos("lobby_position") then return end -- If there's already another position, do not overwrite.
		core_game.position = pos
	end,
})

------------------
-- Privileges --
------------------

--- @brief Give customized nametags for those
--- who have the premium or core administrator role on grant/revoke.
--- @param name string the player to update the nametag to
--- @returns void
function core_game.grant_revoke(name)
	local player = minetest.get_player_by_name(name)
	if not player then return end

	-- Administrators
	minetest.after(0, function()
		if minetest.check_player_privs(player, { core_admin = true } ) then
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
		if minetest.get_modpath("premium") and minetest.check_player_privs(player, { has_premium = true } ) then
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
	on_grant = core_game.grant_revoke,
	on_revoke = core_game.grant_revoke,
})

----------------
-- Variables --
----------------

core_game.game_started = false -- Variable to verify if a race has started or not
core_game.is_end = {} -- Array for multiple players to verify if they have ended the race or not
core_game.count = {} -- Array for the players' countdown

core_game.is_waiting_end = {} -- Array to show the players' a HUD to wait for the current race to finish.
							  -- This comes handy when you wanna let know all the players there's a current race running.
core_game.is_waiting = {} -- Array to show the players' a HUD to wait for more players to join.
						  -- The minimum default value is 4 players.
core_game.player_count = 0 -- Player count in a race. This is decreased if a player leaves and they were in a race.
						   -- Used to check who was in the 1st place, 2nd place, 3rd place, etc..
core_game.players_that_won = {} -- An array to save all the players who won, in their respective place.
core_game.show_leaderboard = false -- Utility boolean to show the leaderboard at the end of the race.

local run_once = {} -- An array to ensure a player hasn't ran more than one time the select car formspec.
					-- This comes handy to not run this in the globalstep function.
local use_hovercraft = {} -- An array to save the players who chose to use the Hovercraft.
local use_car01 = {} -- An array to save the players who chose to use CAR01.
core_game.ran_once = {} -- Utility array to make sure the player hasn't stand on the start race block more than once.

core_game.pregame_started = false -- The variable's name says it all. :)
local pregame_count = 20 -- A variable to save the pregame countdown. This can be customized to any number.
local already_ran = false -- A variable to make sure if the pregame countdown has been already ran.
local pregame_count_ended = false -- A variable to remove the pregame countdown HUD for those who weren't the first to run the countdown.

local racecount_check = {} -- An array used to store the value if a player's countdown already started.
local max_racecount = 130 -- Maximum value for the race count (default 180)

----------------
-- Overrides --
----------------

-- Override the hand item
-- Do not let users break any nodes but let them rightclick on items
minetest.override_item("", {
	range = 4,
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly = nil,
			cracky  = nil,
			snappy  = nil,
			choppy  = nil,
			oddly_breakable_by_hand = nil,
			-- dig_immediate group doesn't use value 1. Value 3 is instant dig
			dig_immediate =
				{times = {[2] = nil, [3] = nil}, uses = 0, maxlevel = 0},
		},
		damage_groups = {fleshy = 1},
	}
})

local old_default_can_interact_with_node = default.can_interact_with_node
function default.can_interact_with_node(player, pos)
	if minetest.check_player_privs(player, { core_admin = true }) then
		return true
	end
	return old_default_can_interact_with_node(player, pos)
end

-- Do not allow players to dig/place nodes if they don't have the `core_admin` privilege
local old_minetest_item_place_node = minetest.item_place_node
function minetest.item_place_node(itemstack, placer, pointed_thing)
	if not minetest.check_player_privs(placer, { core_admin = true }) then
		minetest.chat_send_player(placer:get_player_name(), "You're not allowed to place nodes unless you are a staff. If this is a mistake, please contact the server administrator.")
		return itemstack
	end
	return old_minetest_item_place_node(itemstack, placer, pointed_thing)
end

local old_minetest_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	if not minetest.check_player_privs(digger, { core_admin = true }) then
		minetest.chat_send_player(digger:get_player_name(), "You're not allowed to dig nodes unless you are a staff. If this is a mistake, please contact the server administrator.")
		return
	end
	return old_minetest_node_dig(pos, node, digger)
end

-- Override the signs to make them unbreakable and uneditable, only by owners or those who have permissions.
local function register_sign(material, desc, def)
	minetest.register_node(":default:sign_wall_" .. material, {
		description = desc,
		drawtype = "nodebox",
		tiles = {"default_sign_wall_" .. material .. ".png"},
		inventory_image = "default_sign_" .. material .. ".png",
		wield_image = "default_sign_" .. material .. ".png",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		use_texture_alpha = "opaque",
		node_box = {
			type = "wallmounted",
			wall_top    = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
			wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
			wall_side   = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375},
		},
		groups = def.groups,
		legacy_wallmounted = true,
		sounds = def.sounds,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", "field[text;;${text}]")
			meta:set_string("owner", "") -- Added by team PanqKart
		end,
		after_place_node = function(pos, placer)
			-- Added by team PanqKart

			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name() or "")
			meta:set_string("infotext", '')
		end,
		can_dig = function(pos, player)
			-- Added by team PanqKart

			local meta = minetest.get_meta(pos)
			if meta:get_string("infotext") ~= '' then return end

			return default.can_interact_with_node(player, pos)
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			-- Added by team PanqKart
			local player_name = clicker:get_player_name()
			local meta = minetest.get_meta(pos)
			if minetest.is_protected(pos, player_name) or default.can_interact_with_node(clicker, pos) == false then
				minetest.record_protection_violation(pos, player_name)
				meta:set_string("formspec", "")
				return
			else
				meta:set_string("formspec", "field[text;;${text}]")
			end
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			local player_name = sender:get_player_name()
														-- Added by team PanqKart
			if minetest.is_protected(pos, player_name) or default.can_interact_with_node(sender, pos) == false and not material == "wood" then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			local text = fields.text
			if not text then
				return
			end
			if string.len(text) > 512 then
				minetest.chat_send_player(player_name, minetest.get_translator("default")("Text too long"))
				return
			end
			minetest.log("action", player_name .. " wrote \"" .. text ..
				"\" to the sign at " .. minetest.pos_to_string(pos))
			local meta = minetest.get_meta(pos)
			meta:set_string("text", text)

			if #text > 0 then
				meta:set_string("infotext", minetest.get_translator("default")('"@1"', text))
			else
				meta:set_string("infotext", '')
			end
		end,
	})
end

register_sign("wood", minetest.get_translator("default")("Wooden Sign"), {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = 2, attached_node = 1, flammable = 2, oddly_breakable_by_hand = 3}
})

register_sign("steel", minetest.get_translator("default")("Steel Sign"), {
	sounds = default.node_sound_metal_defaults(),
	groups = {cracky = 2, attached_node = 1}
})

----------------
-- Commands --
----------------
minetest.register_chatcommand("change_position", {
	params = "<x y z>",
	description = S("Change lobby's position"),
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- Start: code taken from Minetest builtin teleport command
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if not p.x and not p.y and not p.z then
			return false, S("Wrong usage of command. Use <x y z>")
		end
		-- End: code taken from Minetest builtin teleport command
		core_game.position = {x = p.x, y = p.y, z = p.z}
		return true, S("Changed lobby's position to: <@1>", param)
    end,
})

if minetest.get_modpath("car_shop") then
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
end

--- @brief A function to show a donation formspec
--- to the specified player(s), with donation links and perks.
--- @param name string the player that will be used to show the formspec to
--- @returns the formspec table
local function donate_formspec(name)
    local formspec = {
        "formspec_version[4]",
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
			minetest.show_formspec(name, "core_game:donate", donate_formspec(name))
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
			minetest.show_formspec(param, "core_game:donate", donate_formspec(param))
			return true, S("Donation formspec shown to @1.", param)
		else
			return false, S("Player @1 does not exist or is not online.", param)
		end
	end,
})

----------------------
-- Local functions --
----------------------

--- @brief Reset counters, variables, and savings
--- from the current/previous race. This can prevent crashes/bugs.
--- @param player string the player to reset the values to
--- @returns void
function core_game.reset_values(player)
	if core_game.players_on_race[player] == player then
		core_game.player_count = core_game.player_count - 1
	end
	core_game.is_end[player] = nil
	core_game.players_on_race[player] = nil
	core_game.players_that_won[player] = nil

	core_game.count[player] = nil
	core_game.is_waiting_end[player] = nil
	core_game.is_waiting[player] = nil

	core_game.ran_once[player] = nil
	racecount_check[player] = false
end

--- @brief Save the player in the players that won the race.
--- This is used when the player ends out of the default time.
--- @param player string the player that will be saved in the array
--- @returns void
local function player_count(player)
	if lib_mount.win_count == 1 then
		core_game.players_that_won[0] = player

	elseif lib_mount.win_count == 2 then
		core_game.players_that_won[1] = player

	elseif lib_mount.win_count == 3 then
		core_game.players_that_won[2] = player

	elseif lib_mount.win_count == 4 then
		core_game.players_that_won[3] = player

	elseif lib_mount.win_count == 5 then
		core_game.players_that_won[4] = player

	elseif lib_mount.win_count == 6 then
		core_game.players_that_won[5] = player

	elseif lib_mount.win_count == 7 then
		core_game.players_that_won[6] = player

	elseif lib_mount.win_count == 8 then
		core_game.players_that_won[7] = player

	elseif lib_mount.win_count == 9 then
		core_game.players_that_won[8] = player

	elseif lib_mount.win_count == 10 then
		core_game.players_that_won[9] = player

	elseif lib_mount.win_count == 11 then
		core_game.players_that_won[10] = player

	elseif lib_mount.win_count == 12 then
		core_game.players_that_won[11] = player
	else
		minetest.log("error", "[RACING GAME] An error ocurred while saving the player in the players that won array.")
		return
	end
end

--- @brief Show `3 2 1 GO!` HUD to the given player
--- Start up race count and toggle `core_game.game_started` value to `true`.
--- This function will also reproduce a sound on each number.
--- @param player string the player that will receive the HUD
--- @returns void
local function hud_321(player)
	if core_game.game_started == true or core_game.pregame_started == true then
		minetest.chat_send_player(player:get_player_name(), S("There's a current race running. Please wait until it finishes."))
		core_game.players_on_race[player] = player

		core_game.reset_values(player)
		core_game.waiting_to_end(player)
		return
	end
	local hud = player:hud_add({
		hud_elem_type = "image",
		position      = {x = 0.5, y = 0.5},
		offset        = {x = 0,   y = 0},
		text          = "core_game_3.png",
		alignment     = {x = 0, y = 0},
		scale         = {x = 1, y = 1},
   })
   minetest.after(0.1, function() core_game.pregame_started = true end) -- Make sure all players will be able to make it to the race
	for _,name in pairs(core_game.players_on_race) do
		minetest.sound_play("core_game.race_start", {to_player = name:get_player_name(), gain = 1.0})
	end
   minetest.after(1, function() -- 2
		player:hud_change(hud, "text", "core_game_2.png")
		for _,name in pairs(core_game.players_on_race) do
			minetest.sound_play("core_game.race_start", {to_player = name:get_player_name(), gain = 1.0})
		end
	   minetest.after(1, function() player:hud_change(hud, "text", "core_game_1.png")
		for _,name in pairs(core_game.players_on_race) do
			minetest.sound_play("core_game.race_start", {
				to_player = name:get_player_name(),
				gain = 1.0
			})
		end end) -- Change text to `1` AFTER the text is `2`
   end)
   -- 5
   minetest.after(3, function() player:hud_change(hud, "text", "core_game_go.png") for _,name in pairs(core_game.players_on_race) do minetest.sound_play("core_game.race_go", {to_player = name:get_player_name(), gain = 1.0})
   end core_game.game_started = true end)
   -- 7
   minetest.after(5, function() player:hud_remove(hud) end)
end

--- @brief Start pregame countdown to the given player(s)
--- @details This will start a countdown from 30 to 0. When it reaches 3,
--- it will run the HUD function above for all the players that are waiting.
-- When it reaches 0, it will remove the HUD and will stop the countdown.
--- The countdown variable will decrease only when it is ran once. This is to prevent more than 1 decrease per second.
---
--- For all those who weren't the first player, it will just show the HUD when will the race start.
--- After that, the HUD will be removed and the race will start for the waiting players.
--- @param player string the player that will be used to start the countdown
--- @returns void
local function countDown(player)
    pregame_count = pregame_count - 1
	for _,name in pairs(core_game.players_on_race) do
		if pregame_count == 0 then
			hud_fs.close_hud(name, "core_game:pregame_count")
			pregame_count_ended = true
		elseif pregame_count == 3 then
			hud_321(name)
			pregame_count_ended = true
		end
	end
    if pregame_count == 0 then
        hud_fs.close_hud(player, "core_game:pregame_count")
    else
		hud_fs.show_hud(player, "core_game:pregame_count", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("The race will start in: @1", pregame_count)
			}
		})
		minetest.after(1, function() countDown(player) end)
    end
end

--- @brief Run the countdown function above each second.
--- @param player string the player that will be used to start the countdown
--- @returns void
local function startCountdown(player)
	already_ran = true
    minetest.after(1, function() countDown(player) end)
end

--- @brief Initialize variables for the race startup and
--- show formspec to select car if applicable. Make sure
--- there's not a current racing running, otherwise it will make a mess with the current race.
--- @details We'll start up the pregame countdown as well before starting the race.
--- If the pregame countdown has been ran before, it will just show the HUD for the 2nd, 3rd, etc. players, to make sure
-- the variable isn't decreased more than one time per second. We'll remove the HUD if the current countdown has stopped, as we're using a loop.
--- @param player string the player to be added into the race
--- @returns void
local function start(player)
	core_game.players_on_race[player] = player
	if core_game.game_started == true or core_game.pregame_started == true then
		minetest.chat_send_player(player:get_player_name(), S("There's a current race running. Please wait until it finishes."))

		-- Clear values in case something was stored
		core_game.players_on_race[player] = nil

		core_game.reset_values(player)
		core_game.waiting_to_end(player)
		return
	end

	-- Start: car selection formspec
	-- Ask the player which car they want to use
	local meta = player:get_meta()
	local data = minetest.deserialize(meta:get_string("hovercraft_bought"))

	if data and data.bought_already == true then
		minetest.show_formspec(player:get_player_name(), "core_game:choose_car", core_game.ask_vehicle(player))
	end
	-- End: car selection formspec

	-- Start: cleanup race count and ending booleans
	core_game.is_end = {}
	core_game.count = {}
	core_game.is_waiting = {}
	core_game.players_that_won = {}
	lib_mount.win_count = 1
	-- End: cleanup race count and ending booleans

	minetest.chat_send_player(player:get_player_name(), S("The race will start in a few seconds. Please wait..."))

	-- Remove nametag
	player:set_nametag_attributes({
		color = {a = 0, r = 255, g = 255, b = 255},
	})

	-- Start: HUD/count stuff
	if not already_ran == true then
		startCountdown(player)
	else
		for i=1,pregame_count,1 do
		minetest.after(i, function()
			if pregame_count_ended == true then hud_fs.close_hud(player, "core_game:pregame_count") return end
		hud_fs.show_hud(player, "core_game:pregame_count", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("The race will start in: @1", pregame_count)
			}
		})
	end)
	end
	end
	-- End: HUD/count stuff
end

--- @brief Function that contains the
-- code to successfully end a race at the given time.
-- No player parameter included; this is ran for all players who are on race.
--- @returns void
local function race_end()
	for i,name in pairs(core_game.players_on_race) do
		if not core_game.is_end[name] == true then
			minetest.chat_send_player(name:get_player_name(), S("You lost the race for ending out of time."))
		end
		player_count(name)
		minetest.after(0, function() minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name)) end)
		core_game.player_lost(name)
		minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))

		hud_fs.close_hud(name, "core_game:pending_race")
		for _,player_name in ipairs(minetest.get_connected_players()) do
			core_game.is_waiting_end[player_name] = false
			hud_fs.close_hud(player_name, "core_game:pending_race")
		end
		-- Set nametags once the race ends
		if minetest.check_player_privs(name, { core_admin = true }) then
			name:set_nametag_attributes({
				text = "[STAFF] " .. name:get_player_name(),
				color = {r = 255, g = 0, b = 0},
				bgcolor = false
			})
		elseif minetest.check_player_privs(name, { has_premium = true }) then
			name:set_nametag_attributes({
				text = "[VIP] " .. name:get_player_name(),
				color = {r = 255, g = 255, b = 0},
				bgcolor = false
			})
		else
			name:set_nametag_attributes({
				text = name:get_player_name(),
				color = {r = 255, g = 255, b = 255},
				bgcolor = false
			})
			if i == #core_game.players_on_race then -- Reset variables once the code runs for the last player
				minetest.after(0, function()
					core_game.player_count = 0
					core_game.players_on_race = {}
				end)
			end
		end
		name:set_physics_override({
			speed = 1, -- Set speed back to normal
			jump = 1, -- Set jump back to normal
		})
	end
end

------------------------------------------------------
-- Minetest `on_register` and miscellaneous callbacks
------------------------------------------------------

minetest.register_on_joinplayer(function(player)
	minetest.after(0.2, function()
		if type(core_game.position) == "string" then
			core_game.position = minetest.string_to_pos(core_game.position)
		end
		if not core_game.position or not minetest.setting_get_pos("lobby_position") then
			core_game.position = player:get_pos()
		end
		local meta = minetest.get_meta(core_game.position)

		-- Let's use the position of the `spawn_node` node. This is very useful
		-- when placing the lobby schematic and not the node itself.
		if meta and minetest.string_to_pos(meta:get_string("lobby_position")) then
			player:set_pos(minetest.string_to_pos(meta:get_string("lobby_position")))
			minetest.log("action", "`spawn_node` node position was used for player " .. player:get_player_name() .. ". Successfully teleported.")
		else
			-- If not found, use the default position defined in settings
			player:set_pos(core_game.position)
		end
	end)
	minetest.log("action", "[RACING GAME] Player " .. player:get_player_name() .. " joined and was teleported to the lobby successfully.")

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
	minetest.log("action", "[RACING GAME] Player " .. player:get_player_name() .. " died. Teleported to the lobby successfully.")
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_all(S("@1 just joined! Give them a warm welcome to our community!", player:get_player_name()))
end)

minetest.register_on_leaveplayer(function(player)
	-- Reset all values to prevent crashes
	core_game.reset_values(player)
end)

-- Keep players and map(s) protected
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	minetest.after(0, function() player:set_hp(player:get_hp() + damage) end)
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if hp_change < 0 then
		minetest.after(0, function() player:set_hp(player:get_hp() - hp_change) end)
	end
end)

--------------------------
-- Core game functions --
--------------------------

--- @brief Utility function to show the scoreboard
--- for the specified player(s).
--- @param name string the player that will be used to show the formspec to
--- @returns the formspec table
function core_game.show_scoreboard(name)
	local formspec

	if core_game.player_count == 1 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds;1]",
    }
elseif core_game.player_count == 2 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds " ..";1]",
    }
elseif core_game.player_count == 3 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds;1]",
    }
elseif core_game.player_count == 4 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds;1]",
    }
elseif core_game.player_count == 5 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds;1]",
    }
elseif core_game.player_count == 6 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds;1]",
    }
elseif core_game.player_count == 7 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds;1]",
    }
elseif core_game.player_count == 8 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds" ..
		"," .. "8th 					" .. core_game.players_that_won[7]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[7]] .. " seconds;1]",
    }
elseif core_game.player_count == 9 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds" ..
		"," .. "8th 					" .. core_game.players_that_won[7]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[7]] .. " seconds" ..
		"," .. "9th 					" .. core_game.players_that_won[8]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[8]] .. " seconds;1]",
    }
elseif core_game.player_count == 10 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds" ..
		"," .. "8th 					" .. core_game.players_that_won[7]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[7]] .. " seconds" ..
		"," .. "9th 					" .. core_game.players_that_won[8]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[8]] .. " seconds" ..
		"," .. "10th 					" .. core_game.players_that_won[9]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[9]] .. " seconds;1]",
    }
elseif core_game.player_count == 11 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds" ..
		"," .. "8th 					" .. core_game.players_that_won[7]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[7]] .. " seconds" ..
		"," .. "9th 					" .. core_game.players_that_won[8]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[8]] .. " seconds" ..
		"," .. "10th 					" .. core_game.players_that_won[9]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[9]] .. " seconds" ..
		"," .. "11th 					" .. core_game.players_that_won[10]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[10]] .. " seconds;1]",
    }
elseif core_game.player_count == 12 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
        "table[0.3,1.25;10,3;scoreboard;" .. S("Place					Player name					Race count") .. ",," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds" ..
		"," .. "6th 					" .. core_game.players_that_won[5]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[5]] .. " seconds" ..
		"," .. "7th 					" .. core_game.players_that_won[6]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[6]] .. " seconds" ..
		"," .. "8th 					" .. core_game.players_that_won[7]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[7]] .. " seconds" ..
		"," .. "9th 					" .. core_game.players_that_won[8]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[8]] .. " seconds" ..
		"," .. "10th 					" .. core_game.players_that_won[9]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[9]] .. " seconds" ..
		"," .. "11th 					" .. core_game.players_that_won[10]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[10]] .. " seconds" ..
		"," .. "12th 					" .. core_game.players_that_won[11]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[11]] .. " seconds;1]",
    }
else
	print("[RACING GAME] Failed to show leaderboard")
	minetest.log("error", "[RACING GAME] Failed to show leaderboard")
end

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Ask the user which vehicle they wanna use.
--- This only applies when they have bought the Hovercraft.
--- @param name string the player variable to use (in this case not being used)
--- @returns void
function core_game.ask_vehicle(name)
    local text = S("Which car/vehicle do you want to use?")

    local formspec = {
        "formspec_version[4]",
        "size[7,3.75]",
        "label[0.5,0.5;", minetest.formspec_escape(text), "]",
        "button_exit[0.3,2.3;3,0.8;use_hovercraft;Hovercraft]",
		"button_exit[3.8,2.3;3,0.8;use_car;Car01]"
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Show a HUD to the specified player
--- that there's a current race running.
--- @param player string the player to show the HUD to
--- @returns void
function core_game.waiting_to_end(player)
	hud_fs.show_hud(player, "core_game:pending_race", {
		{type = "size", w = 40, h = 0.5},
		{type = "position", x = 0.9, y = 0.9},
		{
			type = "label", x = 0, y = 0,
			label = S("Waiting for the current race to finish...")
		}
	})
	core_game.is_waiting_end[player] = true
end

--- @brief Utility function to reset the necessary
--- variables/values when a races end. It will also
--- teleport the user to the lobby after 3.5 seconds.
--- NOTE: this is and should be used only when the user's the last player to win.
--- @param player string the player that will be sent to the lobby
--- @returns void
function core_game.player_lost(player)
	-- Set nametags once the race ends
	if minetest.check_player_privs(player, { core_admin = true }) then
		player:set_nametag_attributes({
			text = "[STAFF] " .. player:get_player_name(),
			color = {r = 255, g = 0, b = 0},
			bgcolor = false
		})
	elseif minetest.check_player_privs(player, { has_premium = true }) then
		player:set_nametag_attributes({
			text = "[VIP] " .. player:get_player_name(),
			color = {r = 255, g = 255, b = 0},
			bgcolor = false
		})
	else
		player:set_nametag_attributes({
			text = player:get_player_name(),
			color = {r = 255, g = 255, b = 255},
			bgcolor = false
		})
	end

	already_ran = false
	pregame_count = 20
	pregame_count_ended = false

	core_game.show_leaderboard = true
	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()

		if entity then
			lib_mount.detach(player, {x=0, y=0, z=0})
			entity.object:remove()
		end
	end
	minetest.after(3.5, function()
		player:set_pos(core_game.position)
		hud_fs.close_hud(player, "core_game:race_count")
	end)
	core_game.is_end[player] = true
	core_game.game_started = false

	core_game.pregame_started = false
	core_game.ran_once = {}
	racecount_check[player] = false
end

--- @brief Select a random car between CAR01 and Hovercraft
--- for the specified user. This is useful when the user didn't select
--- any car while the formspec was up and the game started.
--- @param player string the player that will be attached to the random vehicle
--- @param use_message boolean whether to notify the player or not
--- @returns void
function core_game.random_car(player, use_message)
	local pname = player:get_player_name()
	local random_value = math.random(1, 2)

	if random_value == 1 then
		if use_message == true then
			minetest.chat_send_player(pname, S("You will use CAR01 in the next race."))
		end

		minetest.after(0.1, function()
			local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:car_black", nil)
			if obj then
				lib_mount.attach(obj:get_luaentity(), player, false, 0)
			end
		end)
	elseif random_value == 2 then
		if use_message == true then
			minetest.chat_send_player(pname, S("You will use the Hovercraft in the next race."))
		end

		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:hover_blue", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local node = minetest.get_node(vector.subtract(pos, {x=0,y=0.5,z=0}))

		if minetest.get_modpath("special_nodes") then
			if node.name == "special_nodes:tp_lobby" then
				local meta = minetest.get_meta(core_game.position)

				if minetest.string_to_pos(meta:get_string("lobby_position")) then
					player:set_pos(minetest.string_to_pos(meta:get_string("lobby_position")))
				else
					player:set_pos(core_game.position)
				end
			end
		end
	end

	-- Counting stuff!
	-- Special thanks to Warr1024 for helping!
	for _,name in pairs(core_game.players_on_race) do
		if not minetest.get_player_by_name(name:get_player_name()) then return end

		if not core_game.game_started == true then
			-- Do not let users move before the race starts
			minetest.after(0.1, function() name:set_physics_override({speed = 0.001, jump = 0.01}) end)
		end

		if core_game.game_started == true then
			name:set_physics_override({
				speed = 1, -- Set speed back to normal
				jump = 1, -- Set jump back to normal
			})

			if racecount_check[name] == false then
				core_game.count[name] = 0 -- Let's initialize from 0 to prevent crashes
				racecount_check[name] = true
			end

			if core_game.count[name] >= max_racecount then
				race_end() -- Run function to end a race
			end

			minetest.after(0, function()
				if minetest.get_player_by_name(name:get_player_name()) and not core_game.is_end[name] == true then
					core_game.count[name] = core_game.count[name] + dtime
				end
			end)
			if not core_game.is_end[name] == true then
				hud_fs.show_hud(name, "core_game:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = "Race count: " .. core_game.count[name]
					}
				})
			else
				hud_fs.show_hud(name, "core_game:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = S("You finished at: @1 seconds!", core_game.count[name])
					}
				})
			end
		end
	end

	-- Let's separate this from the code above to avoid issues
	for _,name in pairs(core_game.players_on_race) do
		if use_hovercraft[name] == true or use_car01[name] == true then return end
		if core_game.pregame_started == true and not run_once[name] == true then
			local meta = name:get_meta()
			local data = minetest.deserialize(meta:get_string("hovercraft_bought"))

			local player_pos = name:get_pos()

			run_once[name] = true

			if not data then
				minetest.chat_send_player(name:get_player_name(), S("You will use CAR01 in the next race."))
				minetest.after(0.1, function()
					local obj = minetest.add_entity(player_pos, "vehicle_mash:car_black", nil)
					if obj then
						lib_mount.attach(obj:get_luaentity(), name, false, 0)
					end
				end)
				return
			else
				core_game.random_car(name, true)
				minetest.close_formspec(name:get_player_name(), "core_game:choose_car")
			end
		end
		hud_fs.close_hud(name:get_player_name(), "core_game:pending_race")
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
    if formname ~= "core_game:choose_car" then
        return
    end

    if fields.use_hovercraft then
        minetest.chat_send_player(pname, S("You will use Hovercraft in the next race."))

		minetest.after(0.1, function()
			local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:hover_blue", nil)
			if obj then
				lib_mount.attach(obj:get_luaentity(), player, false, 0)
			end
		end)

		use_hovercraft[player] = true
	elseif fields.use_car then
        minetest.chat_send_player(pname, S("You will use CAR01 in the next race."))

		minetest.after(0.1, function()
			local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:car_black", nil)
			if obj then
				lib_mount.attach(obj:get_luaentity(), player, false, 0)
			end
		end)

		use_car01[player] = true
	else -- Show formspec again if they don't click on any field
		if core_game.game_started == false then
			minetest.after(0.2, minetest.show_formspec, player:get_player_name(), formname, core_game.ask_vehicle(player))
		else
			core_game.random_car(player, true)
		end
    end
end)

--- @brief Run start game function and ensure there are
--- the minimum required players to join a race.
--- Similar to the `start` local function above.
--- @param player string the player that will be used to start the race
--- @returns void
function core_game.start_game(player)
	-- Start: reset values in case something was stored
	core_game.reset_values(player)
	-- End: reset values in case something was stored

	-- Start: player count checks
	if not core_game.game_started == true and not core_game.pregame_started == true then
		core_game.player_count = core_game.player_count + 1
	end

	if core_game.player_count < tonumber(minetest.settings:get("minimum_required_players")) then
		hud_fs.show_hud(player, "core_game:waiting_for_players", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("Waiting for players (@1 required)...", tonumber(minetest.settings:get("minimum_required_players")))
			}
		})
		core_game.is_waiting[player] = player
		player:set_physics_override({speed = 0.001, jump = 0.01})

		-- Teleport back to lobby if no players join in the next half and a minute
		minetest.after(90, function()
			if core_game.game_started or core_game.pregame_started or pregame_count_ended == false then return end

			player:set_physics_override({speed = 1, jump = 1})
			core_game.is_waiting[player] = nil
			player:set_pos(core_game.position)
		end)
		return
	elseif core_game.player_count >= tonumber(minetest.settings:get("minimum_required_players")) then
		for _,name in pairs(core_game.is_waiting) do
			start(name)
			hud_fs.close_hud(name:get_player_name(), "core_game:waiting_for_players")
		end
	end
	-- End: player count checks

	-- Start: start race for non-waiting players, or recently joined ones
	start(player)
	-- End: start race for non-waiting players, or recently joined ones
end
