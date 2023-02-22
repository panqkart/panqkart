--[[
	Checkpoint system for the use of multiple laps
	Copyright (C) 2023 David Leal

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

pk_checkpoints = {
    player_lap_count = { },
    player_checkpoint_count = { },
    checkpoint_positions = { },
    is_player_going_reverse = { },
    player_checkpoint_distance = { },
    storage = minetest.get_mod_storage(),
}

local S = minetest.get_translator(minetest.get_current_modname())
local S2 = minetest.get_translator("pk_core")

local storage = pk_checkpoints.storage

-------------
-- Nodes --
-------------

local function show_formspec(name)
    local formspec = {
        "formspec_version[6]",
        "size[4,3]",
        "field[0.5,0.6;2.9,0.5;checkpoint_number;" .. S("") .. ";]",
        "button_exit[0.9,1.7;2,1;save;" .. S("Save") .. "]",
    }

    return table.concat(formspec, "")
end

minetest.register_node("pk_checkpoints:checkpoint", {
    description = S("Checkpoint. Do NOT place unless you know what you're doing."),
    tiles = { "pk_nodes_invisible.png" },
    groups = { not_in_creative_inventory = 1, unbreakable = 1 },
    paramtype2 = "facedir",
    drawtype = "nodebox",
    pointable = false,
    node_box = {
        type = "fixed",
        fixed = {
            { -1.45, -0.5, -1.45, 1.45, 0, 1.45 },
        },
    },
    on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
    can_dig = function(pos, player)
        if not minetest.check_player_privs(player, { core_admin = true }) then
            minetest.chat_send_player(player:get_player_name(), S2("You don't have sufficient permissions to interact with this node. Missing privileges: core_admin"))
            return false
        end
        return true
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", show_formspec())
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)

        if default.can_interact_with_node(clicker, pos) == false then
            meta:set_string("formspec", "")
            return
        end

        meta:set_string("formspec", show_formspec())
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)

        if fields.save then
            if fields.checkpoint == "" then
                minetest.chat_send_player(sender:get_player_name(), S("Please specify a valid checkpoint number."))
                return
            end

            meta:set_string("checkpoint_number", fields.checkpoint)
            meta:set_string("map_name", "")

            minetest.chat_send_player(sender:get_player_name(), S("Successfully updated checkpoint settings!"))
        end
    end,
})

----------------
-- Functions --
----------------

--- @brief Function to properly trigger a level checkpoint.
--- This is very useful for the multiple lap system.
--- @param entity userdata the entity to check the player's checkpoint data
--- @param pos table the position of the checkpoint node
--- @return boolean true if the checkpoint was successfully triggered, false otherwise
function pk_checkpoints.set_checkpoint(entity, pos)
    local distance = vector.distance(pos, entity.object:get_pos())

    -- Get nodes around the entity (if entity exists).
    local minp = entity.object:get_pos()
    local maxp = entity.object:get_pos()

    minp.x = minp.x - 5
    minp.y = minp.y - 5
    minp.z = minp.z - 5

    maxp.x = maxp.x + 5
    maxp.y = maxp.y + 5
    maxp.z = maxp.z + 5

    local nodes = minetest.find_nodes_in_area(minp, maxp, "pk_checkpoints:checkpoint")

    for _, node_pos in pairs(nodes) do
        local meta = minetest.get_meta(node_pos)
        local distance2 = vector.distance(node_pos, entity.object:get_pos())

        if distance2 < distance then
            return false
        else
            if meta:get_string(entity.driver:get_player_name() .. "_has_been_checked") == "true" then
                return false
            end

            -- Safety check.
            if pk_checkpoints.player_checkpoint_count[entity.driver] == nil then
                pk_checkpoints.player_checkpoint_count[entity.driver] = 1
            end

            -- If the checkpoint order is incorrect, do NOT trigger the checkpoint.
            -- This is very useful to prevent the player from triggering the checkpoint backwards.
            if pk_checkpoints.player_checkpoint_count[entity.driver] ~= tonumber(meta:get_string("checkpoint_number")) then
                return false
            end

            meta:set_string(entity.driver:get_player_name() .. "_has_been_checked", "true")
            pk_checkpoints.player_checkpoint_count[entity.driver] = pk_checkpoints.player_checkpoint_count[entity.driver] + 1

            minetest.log("action", "[PANQKART] Player " .. entity.driver:get_player_name() .. " has reached a checkpoint.")
            return true
        end
    end
end

--- @brief Utility function to show the player a
--- waypoint to the missing checkpoint(s).
--- @param entity userdata entity to check the player's checkpoint data
--- @return nil
function pk_checkpoints.show_waypoint(entity)
    for _,value in pairs(pk_checkpoints.checkpoint_positions) do
        local meta = minetest.get_meta(value)

        if meta and meta:get_string(entity.driver:get_player_name() .. "_has_been_checked") ~= "true" then
            local path = minetest.find_path(entity.object:get_pos(), value, 200, 2, 5)

            if path then
                for i = 1, #path do
			        minetest.add_particle({
				        pos = path[i],
				        expirationtime = 5 + 0.2 * i,
				        texture = "pk_checkpoints_waypoint.png",
				        size = 3,
                        playername = entity.driver:get_player_name()
			        })
                end
            end
        else
            minetest.log("error", "[PANQKART/pk_checkpoints] No waypoint found to the missing checkpoint. This is either a pathfinding problem or map error.")
            return
        end
    end
end

--- @brief Utility function to check if a table contains a value.
--- @param table table the table to check
--- @param value any the value to verify if it's in the given table
--- @return boolean true if the table contains the given value
function table.contains(table, value)
    for _,key in pairs(table) do
        if key == value then
            return true
        end
    end
    return false
end

--- @brief Function to clear the checkpoint metadata.
--- Without clearing the metadata, the checkpoint triggers won't work properly.
--- @param player userdata specific player to reset metadata (optional)
--- @return nil
function pk_checkpoints.clear_metadata(player)
    local checkpoint_array = storage:get_string("panqkart_checkpoint_positions") or pk_checkpoints.checkpoint_positions

    for _,value in pairs(checkpoint_array) do
        local meta = minetest.get_meta(value)

        if meta and player then
            meta:set_string(player:get_player_name() .. "_has_been_checked", "")
        else
            -- Preserve checkpoint numbers, but delete everything else.
            local checkpoint_number = meta:get_string("checkpoint_number")

            meta:from_table({ fields = { } })
            meta:set_string("checkpoint_number", checkpoint_number)
        end
    end
end

--------------------
-- Miscellaneous --
--------------------

minetest.register_on_shutdown(function()
    -- Clear checkpoint metadata.
    pk_checkpoints.clear_metadata()

    local players = minetest.get_connected_players()
    for i = 1, #players do
        pk_checkpoints.clear_metadata(players[i])
    end
end)

-- Use an LBM to create a waypoint if a player misses one or more checkpoints.
minetest.register_lbm({
    label = "Clean up checkpoints and store in table",
    name = "pk_checkpoints:checkpoint_management",

    nodenames = { "pk_checkpoints:checkpoint" },
    run_at_every_load = true,

    action = function(pos, node, dtime_s)
        -- Clear the metadata of the checkpoints if there's no current game.
        if not core_game.game_started then
            if not table.contains(pk_checkpoints.checkpoint_positions, pos) then
                table.insert(pk_checkpoints.checkpoint_positions, pos)
            end
            pk_checkpoints.clear_metadata()
        end

        -- Add to the checkpoint positions table without adding the same node twice.
        if not table.contains(pk_checkpoints.checkpoint_positions, pos) then
            table.insert(pk_checkpoints.checkpoint_positions, pos)
        end

        -- Make sure it's ordered in the correct checkpoint number.
        table.sort(pk_checkpoints.checkpoint_positions, function(a, b)
            local meta_a = minetest.get_meta(a)
            local meta_b = minetest.get_meta(b)

            return meta_a:get_string("checkpoint_number") < meta_b:get_string("checkpoint_number")
        end)

        if #pk_checkpoints.checkpoint_positions == core_game.checkpoint_count then
            storage:set_string("panqkart_checkpoint_positions", minetest.pos_to_string(pk_checkpoints.checkpoint_positions))
            minetest.log("action", "[PANQKART/pk_checkpoints] Stored all valid checkpoint positions.")
        end
    end
})
