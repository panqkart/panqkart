--[[
Local and global functions for the `pk_core` mod.

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
local run_once = { } -- An array to ensure a player hasn't run more than one time the select car formspec.
					-- This comes handy to not run this in the globalstep function.
local use_hovercraft = { } -- An array to save the players who chose to use the Hovercraft.
local use_car01 = { } -- An array to save the players who chose to use CAR01.
local already_ran = false -- A variable to make sure if the pregame countdown has been already run.
local pregame_count_ended = false -- A variable to remove the pregame countdown HUD for those who weren't the first to run the countdown.

local racecount_check = { } -- An array used to store the value if a player's countdown already started.
local max_racecount = tonumber(minetest.settings:get("max_racecount")) or 320 -- Maximum value for the race count (default 230)
local ended_race = { } -- This array is useful when:
					  -- 1. A player joins a race. The minimum player count requirement is not satisifed.
					  -- 2. Another player joins the race. The count is now satisfied.
					  -- 3. The race lasts less than 90 seconds, which is the limit to teleport a player back to the lobby if they're waiting for more players to join.
					  -- 4. This variable prevents the player being teleported back to the lobby even if they're not in a race and if it ended.

----------------------
-- Local functions --
----------------------

--- @brief Save the player in the players that won the race.
--- This is used when the player ends out of the default time.
--- @param player string the player that will be saved in the array
--- @returns nil
local function player_count(player)
	for i = 1, core_game.player_count do
		if core_game.players_that_won[i] == nil then
			core_game.players_that_won[i] = player
		end
	end
end

--- @brief Show `3 2 1 GO!` HUD to the given player
--- Start up race count and toggle `core_game.game_started` value to `true`.
--- This function will also reproduce a sound on each number.
--- @param player string the player that will receive the HUD
--- @returns nil
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
        text          = "pk_core_3.png",
        alignment     = {x = 0, y = 0},
        scale         = {x = 1, y = 1},
    })

    minetest.after(0.1, function() core_game.pregame_started = true end) -- Make sure all players will be able to make it to the race
    for _,name in pairs(core_game.players_on_race) do
        minetest.sound_play("pk_core.race_start", {to_player = name:get_player_name(), gain = 1.0})
    end
    minetest.after(1, function() -- 2
        player:hud_change(hud, "text", "pk_core_2.png")
        for _,name in pairs(core_game.players_on_race) do
            minetest.sound_play("pk_core.race_start", {to_player = name:get_player_name(), gain = 1.0})
        end
        minetest.after(1, function() player:hud_change(hud, "text", "pk_core_1.png")
            for _,name in pairs(core_game.players_on_race) do
                minetest.sound_play("pk_core.race_start", {
                    to_player = name:get_player_name(),
                    gain = 1.0
                })
            end end) -- Change text to `1` AFTER the text is `2`
        end)
        -- 5
        minetest.after(3, function() player:hud_change(hud, "text", "pk_core_go.png") for _,name in pairs(core_game.players_on_race) do minetest.sound_play("pk_core.race_go", {to_player = name:get_player_name(), gain = 1.0})
        end core_game.game_started = true
    end)
    -- 7
    minetest.after(5, function() player:hud_remove(hud) end)
end

--- @brief Start pregame countdown to the given player(s)
--- @details This will start a countdown from 30 to 0. When it reaches 3,
--- it will run the HUD function above for all the players that are waiting.
--- When it reaches 0, it will remove the HUD and will stop the countdown.
--- The countdown variable will decrease only when it is run once. This is to prevent more than 1 decrease per second.
---
--- For all those who weren't the first player, it will just show the HUD when will the race start.
--- After that, the HUD will be removed and the race will start for the waiting players.
--- @param player string the player that will be used to start the countdown
--- @returns nil
local function countDown(player)
    core_game.pregame_count = core_game.pregame_count - 1
	for _,name in pairs(core_game.players_on_race) do
		if core_game.pregame_count == 0 then
			hud_fs.close_hud(name, "pk_core:pregame_count")
			pregame_count_ended = true
		elseif core_game.pregame_count == 3 then
			hud_321(name)
			pregame_count_ended = true
		end
	end
	if core_game.pregame_count == 0 then
		hud_fs.close_hud(player, "pk_core:pregame_count")
	else
		hud_fs.show_hud(player, "pk_core:pregame_count", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("The race will start in: @1", core_game.pregame_count)
			}
		})
		minetest.after(1, function() countDown(player) end)
    end
end

--- @brief Run the countdown function above each second.
--- @param player string the player that will be used to start the countdown
--- @returns nil
local function startCountdown(player)
	already_ran = true
    minetest.after(1, function() countDown(player) end)
end

--- @brief Initialize variables for the race startup and
--- show formspec to select car if applicable. Make sure
--- there's not a current racing running, otherwise, it will make a mess with the current race.
--- @details We'll start up the pregame countdown as well before starting the race.
--- If the pregame countdown has been run before, it will just show the HUD for the 2nd, 3rd, etc. players, to make sure
--- the variable isn't decreased more than one time per second. We'll remove the HUD if the current countdown has stopped, as we're using a loop.
--- @param player string the player to be added into the race
--- @returns nil
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
		minetest.show_formspec(player:get_player_name(), "pk_core:choose_car", core_game.ask_vehicle(player))
	end
	-- End: car selection formspec

	-- Start: cleanup race count and ending booleans
	core_game.is_end = { }
	core_game.count = { }
	core_game.is_waiting = { }
	core_game.players_that_won = { }
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
		for i=1,core_game.pregame_count,1 do
			minetest.after(i, function()
				if pregame_count_ended == true then hud_fs.close_hud(player, "pk_core:pregame_count") return end
				hud_fs.show_hud(player, "pk_core:pregame_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = S("The race will start in: @1", core_game.pregame_count)
					}
				})
			end)
		end
	end
	-- End: HUD/count stuff
end

--- @brief Function that contains the
--- code to successfully end a race at the given time.
--- No player parameter included; this is ran for all players who are on a race.
--- @return nil
function core_game.race_end(show_scoreboard)
	for _,name in pairs(core_game.players_on_race) do
		if core_game.is_end[name] ~= true then
			minetest.chat_send_player(name:get_player_name(), S("You lost the race for ending out of time."))
		end
		player_count(name)

		if show_scoreboard ~= false then
			minetest.after(0, function() minetest.show_formspec(name:get_player_name(), "pk_core:scoreboard", core_game.show_scoreboard(name)) end)
		end

		core_game.player_lost(name)
		minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))

		hud_fs.close_hud(name, "pk_core:pending_race")
		for _,player_name in ipairs(minetest.get_connected_players()) do
			core_game.is_waiting_end[player_name] = false
			hud_fs.close_hud(player_name, "pk_core:pending_race")
		end

		-- Set nametags once the race ends
		core_game.nametags(name:get_player_name())

		if next(core_game.players_on_race,_) == nil then
			minetest.after(0.1, function()
				core_game.player_count = 0
				core_game.players_on_race = { }

				-- Cleanup checkpoint information.
				pk_checkpoints.cleanup()
				minetest.log("action", "[PANQKART] Successfully resetted player count, players on race, and checkpoint data.")
			end)
		end

		name:set_physics_override({
			speed = 1, -- Set speed back to normal
			jump = 1, -- Set jump back to normal
		})
	end
end

--------------------------
-- Core game functions --
--------------------------

--- @brief Reset counters, variables, and savings
--- from the current/previous race. This can prevent crashes/bugs.
--- @param player string the player to reset the values to
--- @return nil
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

--- @brief Utility function to show the scoreboard
--- for the specified player(s).
--- @param name string the player that will be used to show the formspec to
--- @returns the formspec table
function core_game.show_scoreboard(name)
	local formspec = {
        "formspec_version[5]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape(S("Final scoreboard, places, and race count.")), "]",
		"table[0.3,1.25;10,3;scoreboard;" .. minetest.formspec_escape(S("Place					Player name					Race count")) .. ",,"
    }

    local text

	-- Show from the very first place to the last place, depending on the player's count.
	for i = 1, #core_game.players_that_won do
        if i == 1 then
            text = "1st"
        elseif i == 2 then
            text = "2nd"
        elseif i == 3 then
            text = "3rd"
        else
			text = tostring(i) .. "th"
		end

        table.insert(formspec,
            text .. " 					" .. core_game.players_that_won[i]:get_player_name() ..
                "												" .. string.format("%.2f", core_game.count[core_game.players_that_won[i]]) .. " " ..  S("seconds") .. ",")
    end

	table.insert(formspec, ";1]")
    return table.concat(formspec, "")
end

--- @brief Ask the user which vehicle they wanna use.
--- This only applies when they have bought the Hovercraft.
--- @param name string the player variable to use (in this case not being used)
--- @returns nil
function core_game.ask_vehicle(name)
    local text = S("Which car/vehicle do you want to use?")

    local formspec = {
        "formspec_version[5]",
        "size[7,3.75]",
        "label[0.5,0.5;", minetest.formspec_escape(text), "]",
        "button_exit[0.3,2.3;3,0.8;use_hovercraft;Hovercraft]",
		"button_exit[3.8,2.3;3,0.8;use_car;CAR01]"
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Show a HUD to the specified player
--- that there's a current race running.
--- @param player userdata the player to show the HUD to
--- @returns nil
function core_game.waiting_to_end(player)
	hud_fs.show_hud(player, "pk_core:pending_race", {
		{type = "size", w = 40, h = 0.5},
		{type = "position", x = 0.9, y = 0.9},
		{
			type = "label", x = 0, y = 0,
			label = S("Waiting for the current race to finish...")
		}
	})

	core_game.is_waiting_end[player] = true
	core_game.spawn_initialize(player, 0.2)
end

--- @brief Utility function to reset the necessary
--- variables/values when a races end. It will also
--- teleport the user to the lobby after 3.5 seconds.
--- NOTE: this is and should be used only when the user's the last player to win.
--- @param player string the player that will be sent to the lobby
--- @returns nil
function core_game.player_lost(player)
	-- Set nametags once the race ends
	core_game.nametags(player:get_player_name())

	lib_mount.win_count = lib_mount.win_count + 1
	already_ran = false

	pregame_count_ended = false
	core_game.pregame_count = 20

	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()

		if entity then
			minetest.after(0.1, function()
				lib_mount.detach(player, vector.new(0,0,0))
				entity.object:remove()
			end)
		end
	end
	minetest.after(3.5, function()
		player:set_pos(core_game.position)
		hud_fs.close_hud(player, "pk_core:race_count")

		-- Remove the reverse HUD from the checkpoints mod.
		if minetest.get_modpath("pk_checkpoints") then
			hud_fs.close_hud(player, "pk_checkpoints:reverse_hud")
		end
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
--- @returns nil
function core_game.random_car(player, use_message)
	local pname = player:get_player_name()
	local random_value = math.random(1, 2)

	local pos = player:get_pos()

	local meta = player:get_meta()
	local data = minetest.deserialize(meta:get_string("hovercraft_bought"))

	if not data then
		if use_message == true then
			minetest.chat_send_player(pname, S("You will use CAR01 in the next race."))
		end
		local obj = minetest.add_entity(pos, "vehicle_mash:car_black", nil)
		if obj then
			lib_mount.attach(obj:get_luaentity(), player, false, 0)
		end
		return -- Do not run code below
	end

	if random_value == 1 then
		if use_message == true then
			minetest.chat_send_player(pname, S("You will use CAR01 in the next race."))
		end

		local obj = minetest.add_entity(pos, "vehicle_mash:car_black", nil)
		if obj then
			lib_mount.attach(obj:get_luaentity(), player, false, 0)
		end
	elseif random_value == 2 then
		if use_message == true then
			minetest.chat_send_player(pname, S("You will use the Hovercraft in the next race."))
		end

		local obj = minetest.add_entity(pos, "vehicle_mash:hover_blue", nil)
		if obj then
			lib_mount.attach(obj:get_luaentity(), player, false, 0)
		end
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local node = minetest.get_node(vector.subtract(pos, vector.new(0, 0.5, 0)))

		if minetest.get_modpath("pk_nodes") then
			if node.name == "pk_nodes:tp_lobby" then
				core_game.spawn_initialize(player, 0.1)
			end
		end
	end

	-- Counting stuff!
	-- Special thanks to Warr1024 for helping!
	for _,name in pairs(core_game.players_on_race) do
		if not minetest.get_player_by_name(name:get_player_name()) then return end

		if not core_game.game_started == true and not core_game.is_end[name] == true then
			-- Do not let users move before the race starts
			minetest.after(0.13, function() name:set_velocity(vector.new(0,0,0)) end)
			minetest.after(0.1, function() name:set_physics_override({speed = 0, jump = 0}) end)
		end

		if core_game.game_started == true then
			name:set_physics_override({
				speed = 1, -- Set speed back to normal
				jump = 1, -- Set jump back to normal
			})

			local attached_to = name:get_attach()
			if not attached_to and not core_game.is_end[name] == true then
				local pos = name:get_pos()

				if use_hovercraft[name] == true then
					local obj = minetest.add_entity(pos, "vehicle_mash:hover_blue", nil)
					if obj then
						lib_mount.attach(obj:get_luaentity(), name, false, 0)
					end
				elseif use_car01[name] == true then
					local obj = minetest.add_entity(pos, "vehicle_mash:car_black", nil)
					if obj then
						lib_mount.attach(obj:get_luaentity(), name, false, 0)
					end
				else
					core_game.random_car(name, false)
				end
			end

			if racecount_check[name] == false then
				core_game.count[name] = 0 -- Let's initialize from 0 to prevent crashes
				racecount_check[name] = true
			end

			if core_game.count[name] >= max_racecount then
				core_game.race_end() -- Run function to end a race
			end

			if minetest.get_player_by_name(name:get_player_name()) and not core_game.is_end[name] == true then
				core_game.count[name] = core_game.count[name] + dtime
			end

			if not core_game.is_end[name] == true then
				hud_fs.show_hud(name, "pk_core:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = S("Race count: @1", string.format("%.2f", core_game.count[name]))
					}
				})
			else
				hud_fs.show_hud(name, "pk_core:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = S("You finished at: @1 seconds!", string.format("%.2f", core_game.count[name]))
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

			-- We do not want to have two or more vehicles.
			local is_attached = name:get_attach()

			if not data and not is_attached then
				minetest.chat_send_player(name:get_player_name(), S("You will use CAR01 in the next race."))
				minetest.after(0.1, function()
					local obj = minetest.add_entity(player_pos, "vehicle_mash:car_black", nil)
					if obj then
						lib_mount.attach(obj:get_luaentity(), name, false, 0)
					end
				end)
				return
			elseif data and not is_attached then
				core_game.random_car(name, true)
				minetest.close_formspec(name:get_player_name(), "pk_core:choose_car")
			end
		end
		hud_fs.close_hud(name:get_player_name(), "pk_core:pending_race")
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname ~= "pk_core:choose_car" then
		return
	end

	local pos = player:get_pos()

	if fields.use_hovercraft then
		minetest.chat_send_player(pname, S("You will use Hovercraft in the next race."))

		minetest.after(0.1, function()
			local obj = minetest.add_entity(pos, "vehicle_mash:hover_blue", nil)
			if obj then
				lib_mount.attach(obj:get_luaentity(), player, false, 0)
			end
		end)

		use_hovercraft[player] = true
	elseif fields.use_car then
		minetest.chat_send_player(pname, S("You will use CAR01 in the next race."))

		minetest.after(0.1, function()
			local obj = minetest.add_entity(pos, "vehicle_mash:car_black", nil)
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
--- @param player userdata the player that will be used to start the race
--- @returns nil
function core_game.start_game(player)
	-- Start: reset values in case something was stored
	core_game.reset_values(player)
	-- End: reset values in case something was stored

	if core_game.player_count >= 12 then
		minetest.chat_send_player(player:get_player_name(), S("The maximum number of players have been reached. Please wait until the current race ends."))

		core_game.spawn_initialize(player, 0.1)
		return
	end

	-- Start: player count checks
	if not core_game.game_started == true and not core_game.pregame_started == true then
		core_game.player_count = core_game.player_count + 1
	end

	local required_players = tonumber(minetest.settings:get("minimum_required_players"))

	if core_game.player_count < required_players then
		if core_game.player_count < required_players and minetest:is_singleplayer() == false then
			minetest.chat_send_player(player:get_player_name(), S("You might not be able to move. Meanwhile, wait until " .. required_players - core_game.player_count .. " more player(s) join."))
		end

		hud_fs.show_hud(player, "pk_core:waiting_for_players", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("Waiting for players (@1 required)...", required_players)
			}
		})

		core_game.is_waiting[player] = player

		player:set_velocity(vector.new(0,0,0))
		player:set_physics_override({speed = 0, jump = 0})

		-- Teleport back to lobby if no players join in the next half and a minute (90 seconds)
		minetest.after(90, function()
			if core_game.game_started or core_game.pregame_started or already_ran == true or ended_race[player] == true then ended_race[player] = false return end

			player:set_physics_override({speed = 1, jump = 1})
			core_game.is_waiting[player] = nil
			player:set_pos(core_game.position)

			hud_fs.close_hud(player:get_player_name(), "pk_core:waiting_for_players")
			core_game.ran_once[player] = nil
			core_game.player_count = core_game.player_count - 1
		end)
		return
	elseif core_game.player_count >= required_players then
		for _,name in pairs(core_game.is_waiting) do
			start(name)
			hud_fs.close_hud(name:get_player_name(), "pk_core:waiting_for_players")
			ended_race[name] = true
		end
	end
	-- End: player count checks

	for _,name in pairs(core_game.is_waiting) do
		hud_fs.show_hud(name, "pk_core:waiting_for_players", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = S("Waiting for players (@1 players / @2 missing)", core_game.player_count, required_players - core_game.player_count)
			}
		})
	end

	-- Start: start race for non-waiting players, or recently joined ones
	start(player)
	-- End: start race for non-waiting players, or recently joined ones
end
