core_game = { }
core_game.position = { x = -50.5, y = 71.5, z = 157.6 } -- Default lobby position
core_game.players_on_race = {} -- Save players on the current race in a vector

minetest.register_privilege("core_admin", {
    description = "Can manage the lobby position and core game configurations.",
    give_to_singleplayer = true,
	give_to_admin = true,
})

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
local ran_once = {} -- Utility array to make sure the player hasn't stand on the start race block more than once.

core_game.pregame_started = false -- The variable's name says it all. :)
local pregame_count = 20 -- A variable to save the pregame countdown. This can be customized to any number.
local already_ran = false -- A variable to make sure if the pregame countdown has been already ran.
local pregame_count_ended = false -- A variable to remove the pregame countdown HUD for those who weren't the first to run the countdown.

local racecount_check = {} -- An array used to store the value if a player's countdown already started.
local max_racecount = 180 -- Maximum value for the race count (default 180)

if tonumber(minetest.settings:get("minimum_required_players")) == nil then
	minetest.settings:set("minimum_required_players", 4) -- SET MINIMUM REQUIRED PLAYERS FOR A RACE
end

-------------
-- Nodes --
-------------
minetest.register_node("core_game:start_race", {
	description = "Start a race!",
	tiles = {"default_grass.png"},
	drop = "",
	light_source = 7,
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
})

minetest.register_node("core_game:junglenoob", { -- WIP, name might/will change
	description = "noob",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
})

----------------
-- Commands --
----------------
minetest.register_chatcommand("change_position", {
	params = "<x y z>",
	description = "Change lobby's position",
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- Start: code taken from Minetest builtin teleport command
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if not p.x and not p.y and not p.z then
			return false, "Wrong usage of command. Use <x y z>"
		end
		-- End: code taken from Minetest builtin teleport command
		core_game.position = {x = p.x, y = p.y, z = p.z}
		return true, "Changed lobby's position to: <" .. param .. ">"
    end,
})

minetest.register_chatcommand("start_race", {
	params = "",
	description = "Start a race with the current game configurations.",
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- TODO: make a start race command with the specified players
	end,
})

local function donate_formspec(name)
    local formspec = {
        "formspec_version[4]",
        "size[10,8]",
        "label[0.375,0.5;", minetest.formspec_escape("Thanks for your interest! When donating, you will get\nin-game perks, a shoutout, a special role, and more!"), "]",
		"label[0.375,1.75;", minetest.formspec_escape("Starting from as little as $0.75 USD, you will get:"), "]",
		"label[1.80,1.40;", minetest.formspec_escape("\n\nDouble coins\nBetter car upgrades\nVIP house to hang out with other VIP members\n\nPrioritized feature requests,\nbug reports, map suggestions\n\nSocial media shoutout (optional)\nSpecial Discord role to stand out"), "]",
		"label[0.375,7.25;", minetest.formspec_escape("You can choose your favorite platform to donate us:\nliberapay.com/Panquesito7 or github.com/sponsors/Panquesito7"), "]",
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

minetest.register_chatcommand("donate", {
	params = "<player>",
	description = "Shows additional information when donating and links for the same.",
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
			return false, "You don't have sufficient permissions to run this command. Missing privileges: ban"
		end

		local player = minetest.get_player_by_name(name)
		if player then
			minetest.show_formspec(param, "core_game:donate", donate_formspec(param))
			return true, "Donation formspec shown to " .. param .. "."
		else
			return false, "Player " .. name .. " does not exist or is not online."
		end
	end,
})

----------------------
-- Local functions --
----------------------

--- @brief Reset counters, variables, and savings
--- from the current/previous race. This can prevent crashes/bugs.
--- @param player the player to reset the values to
--- @returns void
local function reset_values(player)
	if core_game.players_on_race[player] == player then
		core_game.player_count = core_game.player_count - 1
	end
	core_game.is_end[player] = nil
	core_game.players_on_race[player] = nil
	core_game.players_that_won[player] = nil

	core_game.count[player] = nil
	core_game.is_waiting_end[player] = nil
	core_game.is_waiting[player] = nil

	ran_once[player] = nil
	racecount_check[player] = false
end

--- @brief Save the player in the players that won the race.
--- This is used when the player ends out of the default time.
--- @param the player that will be saved in the array
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

--- @brief Start counting the race after starting
--- for the given player in the parameters.
--- @details After 50 seconds pass (which is the limit of the race count,
--- to prevent people from standing AFK without doing anything), it will end the race and
--- will run the `player_lost` function, which can be found below
--- @param player the player to start the count for
--- @returns void
local function count(player)
	for i = 1,50, 1
	do
		if core_game.game_started == false then do break end end
		minetest.after(i, function()
			if core_game.game_started == false then
				hud_fs.close_hud(player, "core_game:race_count")
				return
			end

			if core_game.is_end[player] == true then
				hud_fs.show_hud(player, "core_game:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = "You finished at: " .. core_game.count[player] .. " seconds!"
					}
				})
				if core_game.game_started == false then
					hud_fs.close_hud(player, "core_game:race_count")
					return
				end
				return
			end

			minetest.chat_send_all(core_game.player_count)

			core_game.count[player] = i
			hud_fs.show_hud(player, "core_game:race_count", {
				{type = "size", w = 40, h = 0.5},
				{type = "position", x = 0.9, y = 0.9},
				{
					type = "label", x = 0, y = 0,
					label = "Race count: " .. core_game.count[player]
				}
			})

			if core_game.count[player] == 50 then
				for _,name in pairs(core_game.players_on_race) do
					if not core_game.is_end[name] == true then
						minetest.chat_send_player(name:get_player_name(), "You lost the race for ending out of time.")
					end
					player_count(player)
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
					core_game.player_lost(name)
					minetest.chat_send_player(name:get_player_name(), "Race ended! Heading back to the lobby...")

					hud_fs.close_hud(player, "core_game:pending_race")
					for _,player_name in ipairs(minetest.get_connected_players()) do
						core_game.is_waiting_end[player_name] = false
						hud_fs.close_hud(player_name, "core_game:pending_race")
					end
					core_game.players_on_race = {}
				end
				return
			end
		end)
	end
end

--- @brief Show `3 2 1 GO!` HUD to the given player
--- Start up race count and toggle `core_game.game_started` value to `true`.
--- This function will also reproduce a sound on each number.
--- @param player the player that will receive the HUD
--- @returns void
local function hud_321(player)
	if core_game.game_started == true or core_game.pregame_started == true then
		minetest.chat_send_player(player:get_player_name(), "There's a current race running. Please wait until it finishes.")
		core_game.players_on_race[player] = player

		reset_values(player)
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
   end core_game.game_started = true end)--count(player) end)
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
--- @param player the player that will be used to start the countdown
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
		--if pregame_count == 3 then
			--hud_321(player)
		--end
		hud_fs.show_hud(player, "core_game:pregame_count", {
			{type = "size", w = 40, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = "The race will start in: " .. pregame_count
			}
		})
       	minetest.after(1, function() countDown(player) end)
    end
end

--- @brief Run the countdown function above each second.
--- @param player the player that will be used to start the countdown
--- @returns void
local function startCountdown(player)
	already_ran = true
    --pregame_count = 30
    minetest.after(1, function() countDown(player) end)
end

--- @brief Initialize variables for the race startup and
--- show formspec to select car if applicable. Make sure
--- there's not a current racing running, otherwise it will make a mess with the current race.
--- @details We'll start up the pregame countdown as well before starting the race.
--- If the pregame countdown has been ran before, it will just show the HUD for the 2nd, 3rd, etc. players, to make sure
-- the variable isn't decreased more than one time per second. We'll remove the HUD if the current countdown has stopped, as we're using a loop.
--- @param player the player to be added into the race
--- @returns void
local function start(player)
	core_game.players_on_race[player] = player
	if core_game.game_started == true or core_game.pregame_started == true then
		minetest.chat_send_player(player:get_player_name(), "There's a current race running. Please wait until it finishes.")

		-- Clear values in case something was stored
		core_game.players_on_race[player] = nil

		reset_values(player)
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

	minetest.chat_send_player(player:get_player_name(), "The race will start in a few seconds. Please wait...")

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
				label = "The race will start in: " .. pregame_count
			}
		})
	end)
	end
	end
	-- End: HUD/count stuff
end

--------------------------
-- Core game functions --
--------------------------

--- @brief Utility function to show the scoreboard
--- for the specified player(s).
--- @param name the player that will be used to show the formspec to
--- @returns the formspec table
function core_game.show_scoreboard(name)
	local formspec

	if core_game.player_count == 1 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds;1]",
    }
elseif core_game.player_count == 2 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds " ..";1]",
    }
elseif core_game.player_count == 3 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds;1]",
    }
elseif core_game.player_count == 4 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds;1]",
    }
elseif core_game.player_count == 5 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
		"," .. "2nd 					" .. core_game.players_that_won[1]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[1]] .. " seconds" ..
		"," .. "3rd 					" .. core_game.players_that_won[2]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[2]] .. " seconds" ..
		"," .. "4rd 					" .. core_game.players_that_won[3]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[3]] .. " seconds" ..
		"," .. "5th 					" .. core_game.players_that_won[4]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[4]] .. " seconds;1]",
    }
elseif core_game.player_count == 6 then
	formspec = {
        "formspec_version[4]",
        "size[12,6]",
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
        "label[0.5,0.5;", minetest.formspec_escape("Final scoreboard, places, and race count."), "]",
        "table[0.3,1.25;10,3;use_hovercraft;Place					Player name					Race count,," .. "1st 					" .. core_game.players_that_won[0]:get_player_name() .. "												" .. core_game.count[core_game.players_that_won[0]] .. " seconds" ..
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
--- @param name the player variable to use (in this case not being used)
--- @returns void
function core_game.ask_vehicle(name)
    local text = "Which car/vehicle do you want to use?"

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

minetest.register_on_joinplayer(function(player)
	player:set_pos(core_game.position)
	minetest.log("action", "[RACING GAME] Player " .. player:get_player_name() .. " joined and was teleported to the lobby successfully.")

	minetest.sound_play("core_game.learn", {to_player = player:get_player_name(), gain = 1.0})
end)

minetest.register_on_dieplayer(function(player)
	player:set_pos(core_game.position)
	minetest.log("action", "[RACING GAME] Player " .. player:get_player_name() .. " died. Teleported to the lobby successfully.")
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_all(player:get_player_name() .. " just joined! Welcome to the Racing Game!")
end)

minetest.register_on_leaveplayer(function(player)
	-- Reset all values to prevent crashes
	reset_values(player)
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	minetest.after(0, function() player:set_hp(player:get_hp() + damage) end)
end)

--- @brief Show a HUD to the specified player
--- that there's a current race running.
--- @param player the player to show the HUD to
--- @returns void
function core_game.waiting_to_end(player)
	hud_fs.show_hud(player, "core_game:pending_race", {
		{type = "size", w = 40, h = 0.5},
		{type = "position", x = 0.9, y = 0.9},
		{
			type = "label", x = 0, y = 0,
			label = "Waiting for the current race to finish..."
		}
	})
	core_game.is_waiting_end[player] = true
end

--- @brief Utility function to reset the necessary
--- variables/values when a races end. It will also
--- teleport the user to the lobby after 3.5 seconds.
--- NOTE: this is and should be used only when the user's the last player to win.
--- @param player the player that will be sent to the lobby
--- @returns void
function core_game.player_lost(player)
	already_ran = false
	pregame_count = 20
	pregame_count_ended = false

	core_game.show_leaderboard = true
	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()

		lib_mount.detach(player, {x=0, y=0, z=0})
		entity.object:remove()
	end
	minetest.after(3.5, function()
		player:set_pos(core_game.position)
		hud_fs.close_hud(player, "core_game:race_count")
	end)
	core_game.is_end[player] = true
	core_game.game_started = false
	--core_game.player_count = 0

	core_game.pregame_started = false
	ran_once = {}
	racecount_check[player] = false
end

--- @brief Select a random car between CAR01 and Hovercraft
--- for the specified user. This is useful when the user didn't select
--- any car while the formspec was up and the game started.
--- @param player the player that will be attached to the random vehicle
--- @param use_message whether to notify the player or not
--- @returns void
function core_game.random_car(player, use_message)
	local pname = player:get_player_name()
	local random_value = math.random(1, 2)

	if random_value == 1 then
		if use_message == true then
			minetest.chat_send_player(pname, "You will use CAR01 in the next race.")
		end

		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:car_dark_grey", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)
	elseif random_value == 2 then
		if use_message == true then
			minetest.chat_send_player(pname, "You will use Hovercraft in the next race.")
		end

		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:hover_blue", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local node = minetest.get_node(vector.subtract(pos, {x=0,y=1,z=0}))

		if node.name == "core_game:start_race" and not ran_once[player] == true then
			reset_values(player) -- Reset values in case something was stored
			core_game.start_game(player)
			ran_once[player] = true
		end
	end

	-- Counting stuff yay
	-- Special thanks to Warr1024 for helping!
	for _,name in pairs(core_game.players_on_race) do
		if core_game.game_started == true then

			if racecount_check[name] == false then
				core_game.count[name] = 0 -- Let's initialize from 0 to prevent crashes
				racecount_check[name] = true
			end

			--[[if core_game.is_end[name] == true then
				hud_fs.show_hud(name, "core_game:race_count", {
					{type = "size", w = 40, h = 0.5},
					{type = "position", x = 0.9, y = 0.9},
					{
						type = "label", x = 0, y = 0,
						label = "You finished at: " .. core_game.count[name] .. " seconds!"
					}
				})
				return
			end--]]

			minetest.after(0, function()
				if not core_game.is_end[name] == true then
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
						label = "You finished at: " .. core_game.count[name] .. " seconds!"
					}
				})
			end

			if core_game.count[name] >= max_racecount then
				if not core_game.is_end[name] == true then
					minetest.chat_send_player(name:get_player_name(), "You lost the race for ending out of time.")
				end
				player_count(name)
				minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				core_game.player_lost(name)
				minetest.chat_send_player(name:get_player_name(), "Race ended! Heading back to the lobby...")

				hud_fs.close_hud(name, "core_game:pending_race")
				for _,player_name in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player_name] = false
					hud_fs.close_hud(player_name, "core_game:pending_race")
				end
				core_game.player_count = 0
				core_game.players_on_race = {}
				return
			end
		end
	end

	-- Let's separate this from the code above to avoid issues
	for _,name in pairs(core_game.players_on_race) do
		if use_hovercraft[name] == true or use_car01[name] == true then return end
		if core_game.game_started == true and not run_once[name] == true then
			local meta = name:get_meta()
			local data = minetest.deserialize(meta:get_string("hovercraft_bought"))

			run_once[name] = true

			if not data then
				minetest.chat_send_player(name:get_player_name(), "You will use CAR01 in the next race.")
				local obj = minetest.add_entity(name:get_pos(), "vehicle_mash:car_dark_grey", nil)
				lib_mount.attach(obj:get_luaentity(), name, false, 0)
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
        minetest.chat_send_player(pname, "You will use Hovercraft in the next race.")

		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:hover_blue", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)

		use_hovercraft[player] = true
	elseif fields.use_car then
        minetest.chat_send_player(pname, "You will use CAR01 in the next race.")

		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:car_dark_grey", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)

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
--- @param player the player that will be used to start the race
--- @returns void
function core_game.start_game(player)
	-- Start: reset values in case something was stored
	reset_values(player)
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
				label = "Waiting for players (" .. tonumber(minetest.settings:get("minimum_required_players")) .. " required)..."
			}
		})
		core_game.is_waiting[player] = player
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
