--[[
	Checkpoint system for the use of multiple laps
	Copyright (C) 2022-2023 David Leal

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
    player_checkpoint_distance = { },
    can_win = { },
    checkpoint_positions = { },
}

local S = minetest.get_translator(minetest.get_current_modname())
local S2 = minetest.get_translator("pk_core")

-------------
-- Nodes --
-------------

local function show_formspec(name)
    local formspec = {
        "formspec_version[5]",
        "size[4,3]",
        "field[0.5,0.6;2.9,0.5;checkpoint;" .. S("Checkpoint number") .. ";${checkpoint_number}]",
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
            { -1.45, -0.5, -1.45, 1.45, (0.1 / 16) - 0.5, 1.45 },
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

    minp.x = minp.x - 6
    minp.y = minp.y - 6
    minp.z = minp.z - 6

    maxp.x = maxp.x + 6
    maxp.y = maxp.y + 6
    maxp.z = maxp.z + 6

    local nodes = minetest.find_nodes_in_area(minp, maxp, "pk_checkpoints:checkpoint")

    for _, node_pos in pairs(nodes) do -- luacheck: ignore
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

            -- Let the function calculate the distance later on.
            pk_checkpoints.player_checkpoint_distance[entity.driver] = 0

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

--- @brief If the player is going backwards, show a HUD message
--- stating that they're going backwards and should go back.
--- @param entity table the entity that's going to be used for the checks
--- @return nil
function pk_checkpoints.going_backwards(entity)
    if core_game.game_started then
		local number = 0

		-- The checkpoint count is always above 1. This is needed when checking the metadata checkpoint number.
		-- We must determine whether we subtract 1 value or keep it as-is for the check below.
		if pk_checkpoints.player_checkpoint_count[entity.driver] - 1 == core_game.checkpoint_count then
			number = 1
		end

		if (pk_checkpoints.player_checkpoint_distance[entity.driver] < vector.distance(entity.object:get_pos(),
			pk_checkpoints.checkpoint_positions[pk_checkpoints.player_checkpoint_count[entity.driver] - number]))
			and pk_checkpoints.player_checkpoint_distance[entity.driver] > 0 then

			hud_fs.show_hud(entity.driver, "pk_checkpoints:reverse_hud", {{
				hud_elem_type = "text",
				name = "reverse_hud",
				text = "You're going backwards!",
				number = 0xFF0000,
				position = { x = 0.5, y = 0.5 },
				size = { x = 3.5, y = 3.5 },
				style = 1,
			}})

            minetest.log("action", "[PANQKART/pk_checkpoints] Shown \"going reverse\" HUD for player " .. entity.driver:get_player_name() .. ".")
		else
			hud_fs.close_hud(entity.driver, "pk_checkpoints:reverse_hud")
		end

		-- Store the distance between the player and the checkpoint each 3 seconds, or if a checkpoint is triggered.
		if os.time() % 3 == 0 then
			for _,key in pairs(pk_checkpoints.checkpoint_positions) do
				local meta = minetest.get_meta(key)

				if tonumber(meta:get_string("checkpoint_number")) == pk_checkpoints.player_checkpoint_count[entity.driver] then
					minetest.after(0, function()
						pk_checkpoints.player_checkpoint_distance[entity.driver] = vector.distance(
							entity.object:get_pos(),
							key
						)
					end)


                    minetest.log("info", "[PANQKART/pk_checkpoints] Saving distance between current checkpoint and the player.")
					break -- No more looping.
				end
			end
		end
	end
end

--- @brief Function to trigger the next lap.
--- The player won't be able to win if there's still a pending lap.
--- @details
---
--- The function checks if the player's missing any checkpoints.
--- If so, the lap won't be triggered and the player will need to complete the track properly.
--- If the player passed all the checkpoints, the lap will count and it will reset the checkpoint count to 1.
--- @param entity table the entity to trigger the lap for
--- @param message_delay table whether the message will be shown or not
--- @return nil
function pk_checkpoints.trigger_lap(entity, message_delay)
    if pk_checkpoints.player_checkpoint_count[entity.driver] - 1 ~= core_game.checkpoint_count then
        if not message_delay[entity.driver] then
            minetest.chat_send_player(entity.driver:get_player_name(), S("You have missed @1 checkpoints.", core_game.checkpoint_count - pk_checkpoints.player_checkpoint_count[entity.driver] - 1))
            minetest.chat_send_player(entity.driver:get_player_name(), S("Please go back and complete the race properly. If this is a map mistake, please report it on the Discord community."))

            -- NEEDS DISCUSSING.
            --pk_checkpoints.show_waypoint(entity)

            message_delay[entity.driver] = true
            minetest.after(10, function()
                message_delay[entity.driver] = false
            end)
        end

        minetest.log("info", "[PANQKART/pk_checkpoints] Player " .. entity.driver:get_player_name() .. " has not passed all the " .. core_game.checkpoint_count .. " checkpoints.")
        pk_checkpoints.can_win[entity.driver] = false

        return
    else
        if pk_checkpoints.player_lap_count[entity.driver] ~= core_game.laps_number then
            pk_checkpoints.player_checkpoint_count[entity.driver] = 1
            pk_checkpoints.clear_metadata(entity.driver)

            minetest.log("action", "[PANQKART/pk_checkpoint] Successfully resetted checkpoint data.")
        end
    end

    if pk_checkpoints.player_lap_count[entity.driver] < core_game.laps_number then
        pk_checkpoints.player_lap_count[entity.driver] = pk_checkpoints.player_lap_count[entity.driver] + 1

        if pk_checkpoints.player_lap_count[entity.driver] == core_game.laps_number then
            minetest.chat_send_player(entity.driver:get_player_name(), S("You're on the last lap (@1 out of @2)! Don't give up: you're almost there.", pk_checkpoints.player_lap_count[entity.driver], core_game.laps_number))
        else
            minetest.chat_send_player(entity.driver:get_player_name(), S("You're on the lap @1 out of @2! Keep going.", pk_checkpoints.player_lap_count[entity.driver], core_game.laps_number))
        end

        message_delay[entity.driver] = true
        minetest.after(10, function()
            message_delay[entity.driver] = false
        end)

        minetest.log("action", "[PANQKART/pk_checkpoints] Player " .. entity.driver:get_player_name() .. "'s now on lap " .. pk_checkpoints.player_lap_count[entity.driver] ..
            ". out of " .. core_game.laps_number .. ".")
        pk_checkpoints.can_win[entity.driver] = false

        return
    end

    pk_checkpoints.can_win[entity.driver] = true
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
--- @param player userdata the player to reset the metadata for, specifically
--- @return nil
function pk_checkpoints.clear_metadata(player)
    for _,value in pairs(pk_checkpoints.checkpoint_positions) do
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

--- @brief Utility function to cleanup all
--- `pk_checkpoints` tables and information.
--- This should be called only at the finish/start of a race
--- or when the server is being shut down.
--- @return nil
function pk_checkpoints.cleanup()
    pk_checkpoints.can_win = { }
    pk_checkpoints.checkpoint_positions = { }
    pk_checkpoints.player_checkpoint_count = { }
    pk_checkpoints.player_lap_count = { }
    pk_checkpoints.player_checkpoint_distance = { }

    pk_checkpoints.clear_metadata()
end

--------------------
-- Miscellaneous --
--------------------

minetest.register_on_shutdown(function()
    pk_checkpoints.cleanup()
end)

-- Use an LBM to create a waypoint if a player misses one or more checkpoints.
minetest.register_lbm({
    label = "Clean up checkpoints and store in table",
    name = "pk_checkpoints:checkpoint_management",

    nodenames = { "pk_checkpoints:checkpoint" },
    run_at_every_load = true,

    action = function(pos)
        -- Clear the metadata of the checkpoints if there's no current game.
        if not core_game.game_started then
            if not table.contains(pk_checkpoints.checkpoint_positions, pos) then
                table.insert(pk_checkpoints.checkpoint_positions, pos)
            end

            table.sort(pk_checkpoints.checkpoint_positions, function(a, b)
                local meta_a = minetest.get_meta(a)
                local meta_b = minetest.get_meta(b)

                return meta_a:get_string("checkpoint_number") < meta_b:get_string("checkpoint_number")
            end)

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
    end
})
