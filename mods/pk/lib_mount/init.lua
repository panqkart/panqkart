--[[
	An API framework for mounting objects.

	Copyright (C) 2016 blert2112 and contributors
	Copyright (C) 2019-2023 David Leal (halfpacho@gmail.com) and contributors

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

lib_mount = {
	passengers = { },
	win_count = 0
}

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local crash_threshold = 6.5		-- ignored if enable_crash is disabled
local aux_timer = 0

local is_sneaking = { }
local message_delay = { }
local first_trigger_distance = { }

------------------------------------------------------------------------------

local mobs_redo = false
if minetest.get_modpath("mobs") then
	if mobs.mod and mobs.mod == "redo" then
		mobs_redo = true
	end
end

--
-- Helper functions
--

--local function is_group(pos, group)
--	local nn = minetest.get_node(pos).name
--	return minetest.get_item_group(nn, group) ~= 0
--end

local function node_is(pos, name, entity)
	local node = minetest.get_node(pos)

	if minetest.get_item_group(node.name, "liquid") ~= 0 then
		return "liquid"
	end
	if minetest.get_item_group(node.name, "walkable") ~= 0 then
		return "walkable"
	end

	if node.name == name then
		return true
	end

	-- Trigger the checkpoint system.
	if name == "pk_checkpoints:checkpoint" and entity and entity.driver then
		pk_checkpoints.set_checkpoint(entity, pos)
	end

	return false
end

local function get_sign(i)
	i = i or 0
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return vector.new(x, y, z)
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end


local function ensure_passengers_exists(entity)
	if entity.passengers ~= nil then
		return
	end
	entity.passengers = {}
	if entity.passenger ~= nil or
		entity.passenger_attach_at ~= nil or
		entity.passenger_eye_offset ~= nil then
		table.insert(entity.passengers,{
			player=entity.passenger,
			attach_at=entity.passenger_attach_at,
			eye_offset=entity.passenger_eye_offset
		})
	else
		return
	end
	if entity.passenger2 ~= nil or
		entity.passenger2_attach_at ~= nil or
		entity.passenger2_eye_offset ~= nil then
		table.insert(entity.passengers,{
			player=entity.passenger2,
			attach_at=entity.passenger2_attach_at,
			eye_offset=entity.passenger2_eye_offset
		})
	else
		return
	end
	if entity.passenger3 ~= nil or
		entity.passenger3_attach_at ~= nil or
		entity.passenger3_eye_offset ~= nil then
		table.insert(entity.passengers,{
			player=entity.passenger3,
			attach_at=entity.passenger3_attach_at,
			eye_offset=entity.passenger3_eye_offset
		})
	end
end
-- Copies the specified passenger to the older api. Note that this is one-directional.
-- If something changed in the old api before this is called it is lost.
-- In code you control be sure to always use the newer API and to call this function on every change.
-- If you would like to improove preformance (memory & CPU) by not updating the old API, set
--  entity.new_api to true. This will return from the funciton instead of doing anything.
local function old_copy_passenger(entity,index,player,attach,eye)
	if entity.new_api then
		return
	end
	ensure_passengers_exists(entity)
	if index==1 then  -- Don't forget! Lua indexes start at 1
		if player then
			entity.passenger = entity.passengers[index].player
		end
		if attach then
			entity.passenger_attach_at = entity.passengers[index].attach_at
		end
		if eye then
			entity.passenger_eye_offset = entity.passengers[index].eye_offset
		end
	elseif index==2 then
		if player then
			entity.passenger2 = entity.passengers[index].player
		end
		if attach then
			entity.passenger2_attach_at = entity.passengers[index].attach_at
		end
		if eye then
			entity.passenger2_eye_offset = entity.passengers[index].eye_offset
		end
	elseif index==3 then
		if player then
			entity.passenger3 = entity.passengers[index].player
		end
		if attach then
			entity.passenger3_attach_at = entity.passengers[index].attach_at
		end
		if eye then
			entity.passenger3_eye_offset = entity.passengers[index].eye_offset
		end
	end
end

local function force_detach(player)
	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()
		if entity.driver and entity.driver == player then
			entity.driver = nil
			lib_mount.passengers[player] = nil
		else
			ensure_passengers_exists(entity)
			for i,passenger in ipairs(entity.passengers) do
				if passenger.player == player then -- If it's nil it won't match
					entity.passengers[i].player = nil -- This maintains the behavior where you could have passenger 1 leave but passenger 2 is still there, and they don't move
					lib_mount.passengers[player] = nil

					-- Legacy support
					old_copy_passenger(entity,i,true,false,false)
					break -- No need to continue looping. We found them.
				end
			end
		end
		player:set_detach()
		player_api.player_attached[player:get_player_name()] = false
		player:set_eye_offset(vector.new(0,0,0), vector.new(0,0,0))
	end
end

local function slow_down(entity, max_spd, nodename, value) -- luacheck: ignore
	if not entity or not entity.object then return end -- Safety check

	local pos = entity.object:get_pos() or vector.new(0, 0, 0)
	pos.y = pos.y - 0.5

	local node = minetest.get_node(pos)
	-- Slow down speed when standing on certain node.
	if node.name == nodename then
		max_spd = entity.max_speed_reverse / value
		if get_sign(entity.v) >= 0 then
			max_spd = entity.max_speed_forward / value
		end
		if math.abs(entity.v) > max_spd then
			entity.v = entity.v - get_sign(entity.v)
		end
	end
end

-------------------------------------------------------------------------------

minetest.register_on_leaveplayer(function(player)
	force_detach(player)
end)

minetest.register_on_shutdown(function()
    local players = minetest.get_connected_players()
	for i = 1,#players do
		force_detach(players[i])
	end
end)

minetest.register_on_dieplayer(function(player)
	lib_mount.detach(player, vector.new(0,0,0))
	player:set_eye_offset(vector.new(0,0,0), vector.new(0,0,0))
	return true
end)

-------------------------------------------------------------------------------

function lib_mount.attach(entity, player, is_passenger, passenger_number)
	local attach_at, eye_offset = {}, {}

	if not is_passenger then
		passenger_number = nil
	end

	if not entity.player_rotation then
		entity.player_rotation = vector.new(0,0,0)
	end

	if is_passenger == true then
		-- Legacy support
		ensure_passengers_exists(entity)

		local attach_updated=false
		if not entity.passengers[passenger_number].attach_at then
			entity.passengers[passenger_number].attach_at = vector.new(0,0,0)
			attach_updated=true
		end
		local eye_updated=false
		if not entity.passengers[passenger_number].eye_offset then
			entity.passengers[passenger_number].eye_offset = vector.new(0,0,0)
			eye_updated=true
		end

		attach_at = entity.passengers[passenger_number].attach_at
		eye_offset = entity.passengers[passenger_number].eye_offset

		entity.passengers[passenger_number].player = player
		lib_mount.passengers[player] = player

		-- Legacy support
		old_copy_passenger(entity,passenger_number,true,attach_updated,eye_updated)
	else
		if not entity.driver_attach_at then
			entity.driver_attach_at = vector.new(0,0,0)
		end
		if not entity.driver_eye_offset then
			entity.driver_eye_offset = vector.new(0,0,0)
		end
		attach_at = entity.driver_attach_at
		eye_offset = entity.driver_eye_offset
		entity.driver = player
	end

	force_detach(player)

	player:set_attach(entity.object, "", attach_at, entity.player_rotation)
	player_api.player_attached[player:get_player_name()] = true
	player:set_eye_offset(eye_offset, vector.new(0,0,0))
	minetest.after(0.2, function()
		player_api.set_animation(player, "sit", 30)
	end)
	player:set_look_horizontal(entity.object:get_yaw() + math.rad(90))
end

function lib_mount.detach(player, offset)
	-- Remove kilometres per-hour HUD
	hud_fs.close_hud(player, "lib_mount:speed")

	force_detach(player)
	player_api.set_animation(player, "stand", 30)
	local pos = player:get_pos()
	pos = vector.new(pos.x + offset.x, pos.y + 0.2 + offset.y, pos.z + offset.z)
	minetest.after(0.1, function()
		player:set_pos(pos)
	end)
end

function lib_mount.drive(entity, dtime, is_mob, moving_anim, stand_anim, jump_height, can_fly, can_go_down, can_go_up, enable_crash, moveresult)
	if first_trigger_distance[entity.driver] ~= true and entity.driver and core_game.game_started then
		pk_checkpoints.player_checkpoint_distance[entity.driver] = vector.distance(
				entity.object:get_pos(),
				pk_checkpoints.checkpoint_positions[1]
			)
		first_trigger_distance[entity.driver] = true
	end

	if entity.driver and not minetest.check_player_privs(entity.driver:get_player_name(), {core_admin = true}) then
		if core_game.game_started == false then return end

		if core_game.game_started == true and not core_game.players_on_race[entity.driver] == entity.driver
			or core_game.players_on_race[entity.driver] == nil then
				return
		end
	end

	-- Sanity checks
	if entity.driver and not entity.driver:get_attach() then entity.driver = nil end

	-- Legacy support
	ensure_passengers_exists(entity)
	for i,passenger in ipairs(entity.passengers) do
		if passenger.player and not passenger.player:get_attach() then
			entity.passengers[i].player = nil
			-- Legacy support
			old_copy_passenger(entity,i,true,false,false)
		end
	end

	-- Add kilometres per-hour HUD.
	-- This HUD is removed on `lib_mount.detach`
	if entity.driver then
		hud_fs.show_hud(entity.driver, "lib_mount:speed", {
			{type = "size", w = 3, h = 0.5},
			{type = "position", x = 0.9, y = 0.9},
			{
				type = "label", x = 0, y = 0,
				label = tostring(math.abs(math.floor(entity.v*2.23694*10)/10))
					.. " km/h"
			}
		})
    end

	aux_timer = aux_timer + dtime

	if can_fly and can_fly == true then
		jump_height = 0
	end

	local rot_steer, rot_view = math.pi/2, 0 -- luacheck: ignore
	if entity.player_rotation.y == 90 then
		rot_steer, rot_view = 0, math.pi/2 -- luacheck: ignore
	end

	local acce_y = 0

	local velo = entity.object:get_velocity()
	entity.v = get_v(velo) * get_sign(entity.v)

	-- process controls
	if entity.driver then
		local ctrl = entity.driver:get_player_control()
		if ctrl.aux1 then
			if aux_timer >= 0.2 then
				entity.mouselook = not entity.mouselook
				aux_timer = 0
			end
		end
		if ctrl.up then
			if get_sign(entity.v) >= 0 then
				entity.v = entity.v + entity.accel/10
			else
				entity.v = entity.v + entity.braking/10
			end
		elseif ctrl.down then
			if entity.max_speed_reverse == 0 and entity.v == 0 then return end
			if get_sign(entity.v) < 0 then
				entity.v = entity.v - entity.accel/10
			else
				entity.v = entity.v - entity.braking/10
			end
		end
		local pname = entity.driver:get_player_name()
		if ctrl.sneak then -- Start: Code by rubenwardy, thanks!
			if not is_sneaking[pname] then
				minetest.sound_play("lib_mount.horn", {
					max_hear_distance = 48,
					pitch = 1,
					object = entity.object,
					gain = 1,
					position = entity.object}, true)
			end
			is_sneaking[pname] = true
		else
			is_sneaking[pname] = false
		end -- End: Code by rubenwardy
		if minetest.settings:get_bool("use_mouselook") == true or minetest.settings:get_bool("use_mouselook") == nil then

			if entity.mouselook then
				if ctrl.left then
					entity.object:set_yaw(entity.object:get_yaw()+get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
				elseif ctrl.right then
					entity.object:set_yaw(entity.object:get_yaw()-get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
				end
			else
				-- Still WIP/testing. Contains a few bugs.
				local yaw = entity.object:get_yaw()
				local yaw_delta = entity.driver:get_look_horizontal() - yaw + math.rad(90)
				if yaw_delta > math.pi then
					yaw_delta = yaw_delta - math.pi *2
				elseif yaw_delta < - math.pi then
					yaw_delta = yaw_delta + math.pi* 2
				end
				local yaw_sign = get_sign(yaw_delta)
				if yaw_sign == 0 then
					yaw_sign = 1
				end
				yaw_delta = math.abs(yaw_delta)
				if yaw_delta > math.pi / 2 then
					yaw_delta = math.pi / 2
				end
				local yaw_speed = yaw_delta * entity.turn_spd
				yaw_speed = yaw_speed * dtime
				entity.object:set_yaw(yaw + yaw_sign*yaw_speed)
			end
		else
			if ctrl.left then
				entity.object:set_yaw(entity.object:get_yaw()+get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
			elseif ctrl.right then
				entity.object:set_yaw(entity.object:get_yaw()-get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
			end
		end
		if ctrl.jump then
			if jump_height > 0 and velo.y == 0 then
				velo.y = velo.y + (jump_height * 3) + 1
				acce_y = acce_y + (acce_y * 3) + 1
			end
			if can_go_up and can_fly and can_fly == true then
				velo.y = velo.y + 1
				acce_y = acce_y + 1
			end
		end
		if ctrl.sneak then
			if can_go_down and can_fly and can_fly == true then
				velo.y = velo.y - 1
				acce_y = acce_y - 1
			end
		end
	end

	-- if not moving then set animation and return
	if entity.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		if is_mob and mobs_redo == true then
			if stand_anim and stand_anim ~= nil then
				set_animation(entity, stand_anim)
			end
		end
		return
	end

	-- set animation
	if is_mob and mobs_redo == true then
		if moving_anim and moving_anim ~= nil then
			set_animation(entity, moving_anim)
		end
	end

	if core_game.game_started and entity.driver then entity.owner = entity.driver:get_player_name() end

	if entity.driver and entity.owner == entity.driver:get_player_name() then
		local meta = entity.driver:get_meta()
		if minetest.get_modpath("pk_shop") then
			local hover_bought = minetest.deserialize(meta:get_string("hovercraft_bought"))
			local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))

			-- Hovercraft
			if entity.name == "vehicle_mash:hover_blue" or entity.name == "vehicle_mash:hover_green"
				or entity.name == "vehicle_mash:hover_yellow" or entity.name == "vehicle_mash:hover_red" then
				if hover_bought and hover_bought.bought_already == true then
					if hover_speed then
						entity.max_speed_forward = hover_speed.forward_speed

						entity.max_speed_reverse = hover_speed.reverse_speed
						entity.turn_spd = hover_speed.turn_speed
						entity.accel = hover_speed.accel

						local max_spd = hover_speed.reverse_speed
						if get_sign(entity.v) >= 0 then
							max_spd = hover_speed.forward_speed
						end
						if math.abs(entity.v) > max_spd then
							entity.v = entity.v - get_sign(entity.v)
						end
						slow_down(entity, max_spd, "default:dirt_with_grass", 2)
						slow_down(entity, max_spd, "maptools:grass", 2)
						slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
					else
						local max_spd = entity.max_speed_reverse
						if get_sign(entity.v) >= 0 then
							max_spd = entity.max_speed_forward
						end
						if math.abs(entity.v) > max_spd then
							entity.v = entity.v - get_sign(entity.v)
						end
						slow_down(entity, max_spd, "default:dirt_with_grass", 2)
						slow_down(entity, max_spd, "maptools:grass", 2)
						slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
					end
				else
					local max_spd = entity.max_speed_reverse
					if get_sign(entity.v) >= 0 then
						max_spd = entity.max_speed_forward
					end
					if math.abs(entity.v) > max_spd then
						entity.v = entity.v - get_sign(entity.v)
					end
					slow_down(entity, max_spd, "default:dirt_with_grass", 2)
					slow_down(entity, max_spd, "maptools:grass", 2)
					slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
				end

			else

			-- CAR01
			local data = minetest.deserialize(meta:get_string("speed"))
			if data then
				entity.max_speed_forward = data.forward_speed

				entity.max_speed_reverse = data.reverse_speed
				entity.turn_spd = data.turn_speed
				entity.accel = data.accel

				local max_spd = data.reverse_speed
				if get_sign(entity.v) >= 0 then
					max_spd = data.forward_speed
				end
				if math.abs(entity.v) > max_spd then
					entity.v = entity.v - get_sign(entity.v)
				end
				slow_down(entity, max_spd, "default:dirt_with_grass", 2)
				slow_down(entity, max_spd, "maptools:grass", 2)
				slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
			else
				-- enforce speed limit forward and reverse
				local max_spd = entity.max_speed_reverse
				if get_sign(entity.v) >= 0 then
					max_spd = entity.max_speed_forward
				end
				if math.abs(entity.v) > max_spd then
					entity.v = entity.v - get_sign(entity.v)
				end
				slow_down(entity, max_spd, "default:dirt_with_grass", 2)
				slow_down(entity, max_spd, "maptools:grass", 2)
				slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
			end
		end
	end
	else
		-- enforce speed limit forward and reverse
		local max_spd = entity.max_speed_reverse
		if get_sign(entity.v) >= 0 then
			max_spd = entity.max_speed_forward
		end
		if math.abs(entity.v) > max_spd then
			entity.v = entity.v - get_sign(entity.v)
		end

		slow_down(entity, max_spd, "default:dirt_with_grass", 2)
		slow_down(entity, max_spd, "maptools:grass", 2)
		slow_down(entity, max_spd, "pk_nodes:slow_down", 3)
	end

	-- Stop!
	local s = get_sign(entity.v)
	entity.v = entity.v - 0.02 * s
	if s ~= get_sign(entity.v) then
		entity.object:set_velocity(vector.new(0,0,0))
		entity.v = 0
		return
	end

	-- Stop! (upwards and downwards; applies only if `can_fly` is enabled)
	if can_fly == true then
		local s2 = get_sign(velo.y)
		local s3 = get_sign(acce_y)
		velo.y = velo.y - 0.02 * s2
		acce_y = acce_y - 0.02 * s3
		if s2 ~= get_sign(velo.y) then
			entity.object:set_velocity(vector.new(0,0,0))
			velo.y = 0
			return
		end
		if s3 ~= get_sign(acce_y) then
			entity.object:set_velocity(vector.new(0,0,0))
			acce_y = 0 -- luacheck: ignore
			return
		end
	end

	-- Enforce speed limit when going upwards or downwards (applies only if `can_fly` is enabled)
	if can_fly == true then
		local max_spd_flying = entity.max_speed_downwards
		if get_sign(velo.y) >= 0 or get_sign(acce_y) >= 0 then
			max_spd_flying = entity.max_speed_upwards
		end

		if math.abs(velo.y) > max_spd_flying then
			velo.y = velo.y - get_sign(velo.y)
		end
		if velo.y > max_spd_flying then -- This check is to prevent exceeding the maximum speed; but the above check also prevents that.
			velo.y = velo.y - get_sign(velo.y)
		end

		if math.abs(acce_y) > max_spd_flying then
			acce_y = acce_y - get_sign(acce_y)
		end
	end

	-- Set position, velocity and acceleration
	local p = entity.object:get_pos()
	local new_velo = vector.new(0,0,0)
	local new_acce = vector.new(0,-9.8,0)

	p.y = p.y - 0.5
	local v = entity.v

	if node_is(p, "air") then
		if can_fly == true then
			new_acce.y = 0
			acce_y = acce_y - get_sign(acce_y) -- When going down, this will prevent from exceeding the maximum speed.
		end
	elseif node_is(p, "liquid") then
		if entity.terrain_type == 2 or entity.terrain_type == 3 then
			new_acce.y = 0
			p.y = p.y + 1
			if node_is(p) == "liquid" then
				if velo.y >= 5 then
					velo.y = 5
				elseif velo.y < 0 then
					new_acce.y = 20
				else
					new_acce.y = 5
				end
			else
				if math.abs(velo.y) < 1 then
					local pos = entity.object:get_pos()
					pos.y = math.floor(pos.y) + 0.5
					entity.object:set_pos(pos)
					velo.y = 0
				end
			end
		else
			if entity.driver then
				local meta = entity.driver:get_meta()

				local car01_speed = minetest.deserialize(meta:get_string("speed"))
				local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))

				-- Still WIP; but works.
				if car01_speed and entity.name == "vehicle_mash:car_black" then
					v = v * 0.75
				elseif hover_speed and entity.name == "vehicle_mash:hover_blue" then
					v = v * 0.5
				else
					v = v * 0.25
				end
			end
		end
--	elseif ni == "walkable" then
--		v = 0
--		new_acce.y = 1
	end

	--[[ Set the variable to true if on grass
	if entity.driver then
		if ni == "maptools_grass" or ni == "default_grass" then
			is_on_grass[entity.driver] = true
		elseif ni ~= "maptools_grass" or ni ~= "default_grass" then
			is_on_grass[entity.driver] = false
		end
	end--]]

	-------------------------
	-- Start: checkpoints --
	--------------------------
	if entity and entity.driver and node_is(p, "pk_checkpoints:checkpoint", entity) then
		minetest.log("action", "[PANQKART/lib_mount] Player " .. entity.driver:get_player_name() .. " has reached a checkpoint.")
	end

	-- If the player's going backwards, show a HUD message.
	if entity and entity.driver then
		pk_checkpoints.going_backwards(entity)
	end

	-----------------------
	-- End: checkpoints --
	-----------------------

	-- Teleport the player 34 nodes back when touching this node.
	if entity and entity.driver and node_is(p, "pk_nodes:lava_node") and core_game.is_end[entity.driver] ~= true then
		entity.object:set_pos(vector.new(p.x - -34, p.y + 1, p.z))
	end

	-- Check also below, because the player might be higher.
	local pos_below = vector.new(p.x, p.y - 1.25, p.z)

	if node_is(p, "maptools:black") or node_is(p, "maptools:white") or (node_is(p, "pk_nodes:asphalt") or node_is(pos_below, "pk_nodes:asphalt")) and entity.driver then
		if core_game.is_end[entity.driver] == true or not core_game.game_started == true then return end

		if not core_game.players_on_race[entity.driver] == entity.driver
		or core_game.players_on_race[entity.driver] == nil then
			-- Do not allow people who are NOT on a race to end
			return
		end
		if not entity.driver then return end

		---------------------------
		-- Lap/checkpoint check --
		---------------------------
		if pk_checkpoints.can_win[entity.driver] ~= true then
			pk_checkpoints.trigger_lap(entity, message_delay)
			return
		end

		local meta = entity.driver:get_meta()
		local data = minetest.deserialize(meta:get_string("player_coins"))
		core_game.is_end[entity.driver] = true

		local text
		local coin_amount = { }

		-- Maximum 12 players per race, so let's do this twelve times in a loop.
		for i = 1, 12 do
			if i == 1 then
				text = S("You're in 1st place! Congratulations!")

				if data then
					-- Premium support.
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data.gold_coins = data.gold_coins + 6
						data.silver_coins = data.silver_coins + 12
						data.bronze_coins = data.bronze_coins + 20

						coin_amount = {
							6,
							12,
							20
						}
					else
						data.gold_coins = data.gold_coins + 3
						data.silver_coins = data.silver_coins + 6
						data.bronze_coins = data.bronze_coins + 10

						coin_amount = {
							3,
							6,
							10
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				-- No data was found previously. New data needs to be serialized.
				else
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data = { gold_coins = 6, silver_coins = 12, bronze_coins = 20 }
						minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))

						coin_amount = {
							6,
							12,
							20
						}
					else
						data = { gold_coins = 3, silver_coins = 6, bronze_coins = 10 }

						coin_amount = {
							3,
							6,
							10
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				end
			elseif i == 2 then
				text = S("You're in 2nd place!")

				-- Premium support.
				if data then
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data.silver_coins = data.silver_coins + 10
						data.bronze_coins = data.bronze_coins + 16
						minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))

						coin_amount = {
							0,
							10,
							16
						}
					else
						data.silver_coins = data.silver_coins + 5
						data.bronze_coins = data.bronze_coins + 8

						coin_amount = {
							0,
							5,
							8
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				-- No data was found previously. New data needs to be serialized.
				else
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data = { gold_coins = 0, silver_coins = 10, bronze_coins = 16 }
						minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))

						coin_amount = {
							0,
							10,
							16
						}
					else
						data = { gold_coins = 0, silver_coins = 5, bronze_coins = 8 }

						coin_amount = {
							0,
							5,
							8
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				end
			elseif i == 3 then
				text = S("You're in 3rd place!")

				-- Premium support.
				if data then
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data.bronze_coins = data.bronze_coins + 10
						minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))

						coin_amount = {
							0,
							0,
							10
						}
					else
						data.bronze_coins = data.bronze_coins + 5

						coin_amount = {
							0,
							0,
							5
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				-- No data was found previously. New data needs to be serialized.
				else
					if minetest.get_modpath("pk_premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
						data = { gold_coins = 0, silver_coins = 0, bronze_coins = 10 }
						minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))

						coin_amount = {
							0,
							0,
							10
						}
					else
						data = { gold_coins = 0, silver_coins = 0, bronze_coins = 5 }

						coin_amount = {
							0,
							0,
							5
						}
					end
					meta:set_string("player_coins", minetest.serialize(data))
				end
			else
				text = S("You're in @1 place!", i .. S("th"))
			end

			if lib_mount.win_count == i or lib_mount.win_count == 0 then
				minetest.chat_send_player(entity.driver:get_player_name(), text)
				minetest.chat_send_player(entity.driver:get_player_name(),
					S("You won @1 gold coins, @2 silver coins, and @3 bronze coins.", coin_amount[1], coin_amount[2], coin_amount[3]))

				core_game.players_that_won[i] = entity.driver
				lib_mount.win_count = lib_mount.win_count + 1

				-- Remove car from the driver. We do not want them to mess up with the remaining players (if any).
				if entity and entity.object then
					local attached_to = entity.driver:get_attach()
					if attached_to then
						minetest.after(0.1, function()
							lib_mount.detach(entity.driver, vector.new(0,0,0))
							entity.object:remove()
						end)
					end
				end

				if core_game.player_count == i then
					core_game.players_that_won[i] = entity.driver

					hud_fs.close_hud(entity.driver, "pk_core:pending_race")
					for _,player in ipairs(minetest.get_connected_players()) do
						core_game.is_waiting_end[player] = false
						hud_fs.close_hud(player, "pk_core:pending_race")
					end

					for _,name in pairs(core_game.players_on_race) do
						minetest.show_formspec(name:get_player_name(), "pk_core:scoreboard", core_game.show_scoreboard(name))
					end

					minetest.after(0.1, function() -- Let's prevent small bugs :')
						core_game.player_count = 0
						for _,name in pairs(core_game.players_on_race) do
							minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
							core_game.player_lost(name)

							core_game.players_on_race = { }

							-- Cleanup checkpoint information.
							pk_checkpoints.cleanup()
						end
					end)
					return
				end

				break -- No more looping.
			end
		end

		-- Here the race ends. Run end race code.
		if lib_mount.win_count == 12 then
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))
			core_game.players_that_won[12] = entity.driver

			hud_fs.close_hud(entity.driver, "pk_core:pending_race")
			for _,player in ipairs(minetest.get_connected_players()) do
				core_game.is_waiting_end[player] = false
				hud_fs.close_hud(player, "pk_core:pending_race")
			end

			for _,name in pairs(core_game.players_on_race) do
				minetest.show_formspec(name:get_player_name(), "pk_core:scoreboard", core_game.show_scoreboard(name))
			end

			minetest.after(0.1, function() -- Let's prevent small bugs :')
				core_game.player_count = 0
				for _,name in pairs(core_game.players_on_race) do
					minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))

					core_game.player_lost(name)
					core_game.players_on_race = { }

					-- Cleanup checkpoint information.
					pk_checkpoints.cleanup()
				end
			end)
		end
		minetest.chat_send_player(entity.driver:get_player_name(), S("Game's up! You finished the race in @1 seconds.", string.format("%.2f", core_game.count[entity.driver])))
	end

	-- UNUSED:
	--velo.y = 6 -- This will make the vehicle jump

	new_velo = get_velocity(v, entity.object:get_yaw() - rot_view, velo.y)
	new_acce.y = new_acce.y + acce_y

	entity.object:set_velocity(new_velo)
	entity.object:set_acceleration(new_acce)

	-- CRASH!
	if enable_crash then
		local intensity = entity.v2 - v
		if intensity >= crash_threshold then
			if is_mob then
				entity.object:set_hp(entity.object:get_hp() - intensity)
			else
				if entity.driver then
					local drvr = entity.driver
					lib_mount.detach(drvr, vector.new(0,0,0))
					drvr:set_velocity(new_velo)
					drvr:set_hp(drvr:get_hp() - intensity)
				end

				ensure_passengers_exists(entity)-- Legacy support
				for _,passenger in ipairs(entity.passengers) do
					if passenger.player then
						local pass = passenger.player
						lib_mount.detach(pass, vector.new(0,0,0))  -- This function already copies to old API
						pass:set_velocity(new_velo)
						pass:set_hp(pass:get_hp() - intensity)
					end
				end
				local pos = entity.object:get_pos()

				------------------
				-- Handle drops --
				------------------

				-- `entity.drop_on_destory` is table which stores all the items that will be dropped on destroy.
				-- It will drop one of those items, from `1` to the length, or the end of the table.

				local i = math.random(1, #entity.drop_on_destroy)
				local j = math.random(2, #entity.drop_on_destroy)

				minetest.add_item(pos, entity.drop_on_destroy[i])
				if i ~= j then
					minetest.add_item(pos, entity.drop_on_destroy[j])
				end

				minetest.sound_play("lib_mount.crash", {
					max_hear_distance = 48,
					pitch = .7,
					gain = 10,
					object = entity.object
				}, true)

				entity.removed = true
				-- delay remove to ensure player is detached
				minetest.after(0.1, function()
					entity.object:remove()
				end)
			end
		end
	end

	entity.v2 = v
end
