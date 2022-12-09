--[[
Places the lobby and level schematics on the first run. Existing worlds will be affected.

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

local modstorage = minetest.get_mod_storage()

minetest.register_on_newplayer(function(player)
    if modstorage:get_string("schematic") ~= "false" then
        -- In case the player isn't in {0,0,0}, teleport them there.
        player:set_pos({x = 0, y = 0, z = 0})

        minetest.chat_send_player(player:get_player_name(), "Please wait while the schematics are being placed. It could take up to 15 minutes.")
        minetest.chat_send_player(player:get_player_name(), "Do not pause if you're in singleplayer mode, otherwise, the schematics won't be placed.")
        minetest.chat_send_player(player:get_player_name(), "\nThank you for downloading PanqKart. Join our Discord server while you wait: https://discord.gg/HEweZuF3Vv")

        local value
        local pos = player:get_pos()

        local filenames = {"lobby.we", "level.we"}
        for _,name in pairs(filenames) do

            local file, err = io.open(minetest.get_modpath("core_game") .. "/schems/" .. name, "rb")
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
                local lobby_count = worldedit.fixlight({x = 5, y = 5, z = 105}, {x = 92, y = 37, z = 0})
                local level_count = worldedit.fixlight({x = 0, y = 325, z = 0}, {x = 187, y = 300, z = 317})

                minetest.log("action", "[PANQKART] " .. level_count .. " nodes were light-fixed in the level, " .. lobby_count .. " nodes were light-fixed in the lobby.")
            else
                minetest.log("error", "[PANQKART] Failed to read schematic. Contact us for support if the error persists.")
                minetest.log("error", "[PANQKART] Schematic error message: " .. err)

                return
            end
        end

        -- Assuming the player spawned in 0,0,0, it will TP them to the level, which will then
        -- generate the `player_positions.txt` file. After that, the player must be teleported to the lobby.
        minetest.after(0.3, function() player:set_pos({x = 60, y = 310, z = 230}) end)
        minetest.after(0.8, function() core_game.spawn_initialize(player, 0) end)
    end
    modstorage:set_string("schematic", "false")
end)
