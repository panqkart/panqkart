--[[
Includes everything to make racing work right, such as player counting, scoreboard, lobby position, and more.

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

core_game = {
	S = S,
	modstorage = minetest.get_mod_storage()
}

--------------------------------
-- Assertion/security checks --
--------------------------------

local minimum_required_players = minetest.settings:get("minimum_required_players")
if tonumber(minimum_required_players) == nil then
	minetest.settings:set("minimum_required_players", 4) -- SET MINIMUM REQUIRED PLAYERS FOR A RACE
end

assert(
	tonumber(minimum_required_players) < 12,
	"The minimum required players cannot be over 12 players. Please specify a number between 1-12. Contact us if you need any help."
)
assert(
	minetest.get_mapgen_setting("mg_name") == "singlenode",
	"In order to play PanqKart, you must set your mapgen to 'singlenode'. If you need any help, don't hesitate to contact us via our Discord."
)

----------------
-- Variables --
----------------

core_game.players_on_race = { } -- Save players on the current race in a vector
core_game.game_started = false -- Variable to verify if a race has started or not
core_game.is_end = { } -- Array for multiple players to verify if they have ended the race or not
core_game.count = { } -- Array for the players' countdown

core_game.is_waiting_end = { } -- Array to show the players' a HUD to wait for the current race to finish.
							  -- This comes in handy when you wanna let know all the players there's a current race running.
core_game.is_waiting = { } -- Array to show the players' a HUD to wait for more players to join.
						  -- The minimum default value is 4 players.
core_game.player_count = 0 -- Player count in a race. This is decreased if a player leaves and they were in a race.
						   -- Used to check who was in the 1st place, 2nd place, 3rd place, etc..
core_game.players_that_won = { } -- An array to save all the players who won, in their respective place.
core_game.show_leaderboard = false -- Utility boolean to show the leaderboard at the end of the race.

core_game.ran_once = { } -- Utility array to make sure the player hasn't stood on the start race block more than once.
core_game.pregame_started = false -- The variable's name says it all. :)
core_game.pregame_count = 20 -- A variable to save the pregame countdown. This can be customized to any number.

core_game.laps_number = 3 			-- The number of laps that the track has.
core_game.checkpoint_count = 9		-- The number of checkpoints that the track has (per lap?).

-------------------
-- Lobby/mapgen --
-------------------

dofile(minetest.get_modpath(modname) .. "/mapgen.lua")
dofile(minetest.get_modpath(modname) .. "/schematics.lua")

------------------
-- Privileges --
------------------

dofile(minetest.get_modpath(modname) .. "/privileges.lua")

---------------------
-- Core functions --
---------------------

dofile(minetest.get_modpath(modname) .. "/core_functions.lua")

----------------
-- Commands --
----------------

dofile(minetest.get_modpath(modname) .. "/commands.lua")

-------------------
-- MT callbacks --
-------------------

dofile(minetest.get_modpath(modname) .. "/minetest_callbacks.lua")
