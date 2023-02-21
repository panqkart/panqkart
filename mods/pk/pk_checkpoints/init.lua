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
}

local S = minetest.get_translator(minetest.get_current_modname())
local S2 = minetest.get_translator("pk_core") or S

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
})

----------------
-- Functions --
----------------

--- @brief Function to properly trigger a level checkpoint.
--- This is very useful for the multiple lap system.
--- @param entity userdata the entity to check the player's checkpoint data
--- @param pos table the position of the checkpoint node
--- @return nil
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
--- @return nil
function pk_checkpoints.clear_metadata(player)
    for _,value in pairs(pk_checkpoints.checkpoint_positions) do
        local meta = minetest.get_meta(value)

        if meta and player then
            meta:set_string(player:get_player_name() .. "_has_been_checked", "false")
        else
            meta:from_table({ fields = { } })
        end
    end
end

--------------------
-- Miscellaneous --
--------------------

minetest.register_on_shutdown(function()
    -- Clear the checkpoint metadata.
    pk_checkpoints.clear_metadata()
end)

-- Use an LBM to create a waypoint if a player misses one or more checkpoints.
minetest.register_lbm({
    label = "Create waypoints to the checkpoints",
    name = "pk_checkpoints:waypoint_checkpoint",

    nodenames = { "pk_checkpoints:checkpoint"  },
    run_at_every_load = true,

    action = function(pos, node, dtime_s)
        if not table.contains(pk_checkpoints.checkpoint_positions, pos) then
            table.insert(pk_checkpoints.checkpoint_positions, pos)
        end
    end
})
