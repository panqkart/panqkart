--[[
Places the lobby and level schematics on the first run.

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

local modstorage = core_game.modstorage
local S = minetest.get_translator(minetest.get_current_modname())
local manual_setup = minetest.settings:get_bool("manual_setup")

local do_not_place = false

if manual_setup == true and not manual_setup == nil then
    minetest.log("info", "[PANQKART] Manual setup is enabled. Schematics will not be placed on startup.")
    do_not_place = true
end

-- Check if the `lobby_position.txt` file has any content.
-- If any content is found, it means that the schematics have already been placed.
local lobby_file,err_msg = io.open(minetest.get_worldpath() .. "/lobby_position.txt", "r")
if lobby_file then
    local content = lobby_file:read("*a")
    lobby_file:close()

    if content ~= "" then
        modstorage:set_string("schematic", "false")
        do_not_place = true
    end
else
    minetest.log("error", "[PANQKART] Error while reading lobby position: " .. err_msg .. ".")
end

minetest.register_on_newplayer(function(player)
    if modstorage:get_string("schematic") ~= "false" and minetest.settings:get_bool("modgen_generation") == false and
        (manual_setup == false or manual_setup == nil) then

        if do_not_place == true then return end

        -- In case the player isn't in {0,0,0}, teleport them there.
        player:set_pos(vector.new(0,0,0))

        minetest.chat_send_player(player:get_player_name(), S("Please wait while the schematics are being placed. It could take up to 15 minutes."))
        minetest.chat_send_player(player:get_player_name(), S("Do not pause if you're in singleplayer mode, otherwise, the schematics won't be placed."))

        minetest.chat_send_player(player:get_player_name(), "\n" .. S("Thank you for downloading PanqKart. Join our Discord server while you wait: https://discord.gg/HEweZuF3Vv"))
        minetest.chat_send_player(player:get_player_name(), S("WARNING: Modgen-based generation is recommended. Enable `modgen_generation` in your Minetest settings for a faster setup."))

        local value
        local pos = player:get_pos()

        local filenames = { "lobby.we", "level.we" }
        for _,name in pairs(filenames) do

            local file, err = io.open(minetest.get_modpath("pk_core") .. "/schems/" .. name, "rb")
            -- The level's very big. We don't want it to collapse with the lobby.
            if name == "level.we" then
                pos.y = pos.y + 300
            end

            if file then
                value = file:read("*a")
                file:close()

                worldedit.deserialize(pos, value)
                minetest.log("action", "[PANQKART] The schematic " .. name .. " was placed.")

                -- Sometimes, the lights can be messed up when placing the schematics.
                local lobby_count = worldedit.fixlight(vector.new(5, 5, 105), vector.new(92, 37, 0))
                local level_count = worldedit.fixlight(vector.new(0, 325, 0), vector.new(187, 300, 317))

                minetest.log("action", "[PANQKART] " .. level_count .. " nodes were light-fixed in the level, " .. lobby_count .. " nodes were light-fixed in the lobby.")
            else
                minetest.log("error", "[PANQKART] Failed to read schematic. Contact us for support if the error persists.")
                minetest.log("error", "[PANQKART] Schematic error message: " .. err)

                return
            end
        end

        -- Assuming the player spawned in 0,0,0, it will TP them to the level, which will then
        -- generate the `player_positions.txt` file. After that, the player must be teleported to the lobby.
        minetest.after(0.3, function() player:set_pos(vector.new(60, 310, 230)) end)
        minetest.after(0.8, function() core_game.spawn_initialize(player, 0) end)

        modstorage:set_string("schematic", "false")
    end
end)

minetest.register_on_joinplayer(function(player)
    if minetest.settings:get_bool("modgen_generation") == true or minetest.settings:get_bool("modgen_generation") == nil then
        -- Teleport where the level is located at (temporary).
        -- This will be removed once the multiple-map system is added.

        if modstorage:get_string("schematic") ~= "false" then
            player:set_pos(vector.new(55, 19, 65))

            minetest.after(1, function() player:set_pos(vector.new(-48, 232.5, -285)) end)
            minetest.after(3, function() core_game.spawn_initialize(player, 0) end)
        end

        -- Prevents WorldEdit schematics from being placed if
        -- `modgen_generation` is disabled AFTER `modgen` generated the maps.
        modstorage:set_string("schematic", "false")
    end
end)
