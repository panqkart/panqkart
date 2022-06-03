--[[
	An API framework for mounting objects.

	Copyright (C) 2016 blert2112 and contributors
	Copyright (C) 2019-2022 David Leal (halfpacho@gmail.com) and contributors

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
	passengers = {},
	win_count = 1
}

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local crash_threshold = 6.5		-- ignored if enable_crash is disabled

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

local function node_is(pos)
	local node = minetest.get_node(pos)
	if node.name == "air" then
		return "air"
	end
	-- End/win blocks: white
	if node.name == "maptools:white" then
		return "maptools_white"
	end
	-- End/win blocks: black
	if node.name == "maptools:black" then
		return "maptools_black"
	end
	if minetest.get_item_group(node.name, "liquid") ~= 0 then
		return "liquid"
	end
	if minetest.get_item_group(node.name, "walkable") ~= 0 then
		return "walkable"
	end
	return "other"
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
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function force_detach(player)
	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()
		if entity.driver and entity.driver == player then
			--remove_hud(entity)
			entity.driver = nil
			lib_mount.passengers[player] = nil
		elseif entity.passenger and entity.passenger == player then
			entity.passenger = nil
			lib_mount.passengers[player] = nil
		elseif entity.passenger2 and entity.passenger2 == player then
			entity.passenger2 = nil
			lib_mount.passengers[player] = nil
		elseif entity.passenger3 and entity.passenger3 == player then
			entity.passenger3 = nil
			lib_mount.passengers[player] = nil
		end
		player:set_detach()
		player_api.player_attached[player:get_player_name()] = false
		player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
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
	lib_mount.detach(player, {x = 0, y = 0, z = 0})
	player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	return true
end)

-------------------------------------------------------------------------------

function lib_mount.attach(entity, player, is_passenger, passenger_number)
	local attach_at, eye_offset = {}, {}

	if not is_passenger then
		passenger_number = nil
	end

	if not entity.player_rotation then
		entity.player_rotation = {x=0, y=0, z=0}
	end

	local rot_view = 0
	if entity.player_rotation.y == 90 then
		rot_view = math.pi/2
	end

	if is_passenger == true and passenger_number == 1 then
		if not entity.passenger_attach_at then
			entity.passenger_attach_at = {x=0, y=0, z=0}
		end
		if not entity.passenger_eye_offset then
			entity.passenger_eye_offset = {x=0, y=0, z=0}
		end

		attach_at = entity.passenger_attach_at
		eye_offset = entity.passenger_eye_offset

		entity.passenger = player
		lib_mount.passengers[entity.passenger] = player

	elseif is_passenger == true and passenger_number == 2 then
		if not entity.passenger2_attach_at then
			entity.passenger2_attach_at = {x=0, y=0, z=0}
		end
		if not entity.passenger2_eye_offset then
			entity.passenger2_eye_offset = {x=0, y=0, z=0}
		end

		attach_at = entity.passenger2_attach_at
		eye_offset = entity.passenger2_eye_offset

		entity.passenger2 = player
		lib_mount.passengers[entity.passenger2] = player

	elseif is_passenger == true and passenger_number == 3 then
		if not entity.passenger3_attach_at then
			entity.passenger3_attach_at = {x=0, y=0, z=0}
		end
		if not entity.passenger3_eye_offset then
			entity.passenger3_eye_offset = {x=0, y=0, z=0}
		end

		attach_at = entity.passenger3_attach_at
		eye_offset = entity.passenger3_eye_offset

		entity.passenger3 = player
		lib_mount.passengers[entity.passenger3] = player
	else
		if not entity.driver_attach_at then
			entity.driver_attach_at = {x=0, y=0, z=0}
		end
		if not entity.driver_eye_offset then
			entity.driver_eye_offset = {x=0, y=0, z=0}
		end
		attach_at = entity.driver_attach_at
		eye_offset = entity.driver_eye_offset

		entity.driver = player
	end

	force_detach(player)

	player:set_attach(entity.object, "", attach_at, entity.player_rotation)
	player_api.player_attached[player:get_player_name()] = true
	player:set_eye_offset(eye_offset, {x=0, y=0, z=0})
	minetest.after(0.2, function()
		player_api.set_animation(player, "sit", 30)
	end)
	player:set_look_horizontal(entity.object:get_yaw() - rot_view)
end

function lib_mount.detach(player, offset)
	-- Remove kilometres per-hour HUD
	hud_fs.close_hud(player, "lib_mount:speed")

	force_detach(player)
	player_api.set_animation(player, "stand", 30)
	local pos = player:get_pos()
	pos = {x = pos.x + offset.x, y = pos.y + 0.2 + offset.y, z = pos.z + offset.z}
	minetest.after(0.1, function()
		player:set_pos(pos)
	end)
	player:set_armor_groups({ immortal = 0 })
end

local aux_timer = 0
local is_sneaking = {}

function lib_mount.drive(entity, dtime, is_mob, moving_anim, stand_anim, jump_height, can_fly, can_go_down, can_go_up, enable_crash, moveresult)
	if entity.driver and not minetest.check_player_privs(entity.driver:get_player_name(), {core_admin = true}) then
		if core_game.game_started == false then return end

		if core_game.game_started == true and not core_game.players_on_race[entity.driver] == entity.driver
			or core_game.players_on_race[entity.driver] == nil then
				return
		end
	end

	-- Sanity checks
	if entity.driver and not entity.driver:get_attach() then entity.driver = nil end

	if entity.passenger and not entity.passenger:get_attach() then
		entity.passenger = nil
	end
	if entity.passenger2 and not entity.passenger2:get_attach() then
		entity.passenger2 = nil
	end
	if entity.passenger3 and not entity.passenger3:get_attach() then
		entity.passenger3 = nil
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

	-- Detach passengers automatically in case driver gets killed
	if not entity.driver then
		if entity.passenger then
			lib_mount.detach(entity.passenger, entity.offset)
		end
		if entity.passenger2 then
			lib_mount.detach(entity.passenger2, entity.offset)
		end
		if entity.passenger3 then
			lib_mount.detach(entity.passenger3, entity.offset)
		end
	end

	aux_timer = aux_timer + dtime

	if can_fly and can_fly == true then
		jump_height = 0
	end

	local rot_steer, rot_view = math.pi/2, 0
	if entity.player_rotation.y == 90 then
		rot_steer, rot_view = 0, math.pi/2
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
		if minetest.settings:get_bool("lib_mount.use_mouselook") == true or minetest.settings:get_bool("lib_mount.use_mouselook") == nil then
			if entity.mouselook then
				if ctrl.left then
					entity.object:set_yaw(entity.object:get_yaw()+get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
				elseif ctrl.right then
					entity.object:set_yaw(entity.object:get_yaw()-get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
				end
			else
				entity.object:set_yaw(entity.driver:get_look_yaw() - rot_steer)
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

	-- Stop!
	local s = get_sign(entity.v)
	entity.v = entity.v - 0.02 * s
	if s ~= get_sign(entity.v) then
		entity.object:set_velocity({x=0, y=0, z=0})
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
			entity.object:set_velocity({x=0, y=0, z=0})
			velo.y = 0
			return
		end
		if s3 ~= get_sign(acce_y) then
			entity.object:set_velocity({x=0, y=0, z=0})
			acce_y = 0 -- luacheck: ignore
			return
		end
	end

	if entity.driver and entity.owner then
		local meta = entity.driver:get_meta()
		if minetest.get_modpath("car_shop") then
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
					else
						local max_spd = entity.max_speed_reverse
						if get_sign(entity.v) >= 0 then
							max_spd = entity.max_speed_forward
						end
						if math.abs(entity.v) > max_spd then
							entity.v = entity.v - get_sign(entity.v)
						end
					end
				else
					local max_spd = entity.max_speed_reverse
					if get_sign(entity.v) >= 0 then
						max_spd = entity.max_speed_forward
					end
					if math.abs(entity.v) > max_spd then
						entity.v = entity.v - get_sign(entity.v)
					end
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
			else
				-- enforce speed limit forward and reverse
				local max_spd = entity.max_speed_reverse
				if get_sign(entity.v) >= 0 then
					max_spd = entity.max_speed_forward
				end
				if math.abs(entity.v) > max_spd then
					entity.v = entity.v - get_sign(entity.v)
				end
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
	local new_velo = {x=0, y=0, z=0}
	local new_acce = {x=0, y=-9.8, z=0}

	p.y = p.y - 0.5
	local ni = node_is(p)
	local v = entity.v
	if ni == "air" then
		if can_fly == true then
			new_acce.y = 0
			acce_y = acce_y - get_sign(acce_y) -- When going down, this will prevent from exceeding the maximum speed.
		end
	elseif ni == "liquid" then
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
			v = v*0.25
		end
--	elseif ni == "walkable" then
--		v = 0
--		new_acce.y = 1
	end
	if node_is(p) == "maptools_black" or node_is(p) == "maptools_white" and entity.driver then
		if core_game.is_end[entity.driver] == true or not core_game.game_started == true then return end

		if not core_game.players_on_race[entity.driver] == entity.driver
		or core_game.players_on_race[entity.driver] == nil then
			-- Do not allow people who are NOT on a race to end
			return
		end
		if not entity.driver then return end
		--[[for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			--if name == entity.owner then return end
			if not name == entity.owner and not core_game.count[entity.driver] == core_game.count[player] then
				minetest.chat_send_player(entity.driver:get_player_name(), "You are in 1st place!")
			elseif not core_game.is_end[entity.driver] == true then
				minetest.chat_send_player(entity.driver:get_player_name(), "You are in 2nd place!")
			end
		end--]]
		local meta = entity.driver:get_meta()
		local data = minetest.deserialize(meta:get_string("player_coins"))
		core_game.is_end[entity.driver] = true
		-- Maximum 12 players per race, so let's do this twelve times
		if lib_mount.win_count == 1 then
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 1st place! Congratulations!"))
			minetest.chat_send_player(entity.driver:get_player_name(), S("You won 3 gold coins, 6 silver coins, and 10 bronze coins."))
			core_game.players_that_won[0] = entity.driver

			if data then--car_shop.player_gold_coins[entity.driver] ~= nil or car_shop.player_silver_coins[entity.driver] ~= nil or car_shop.player_bronze_coins[entity.driver] ~= nil then
				--car_shop.player_gold_coins[entity.driver] = car_shop.player_gold_coins[entity.driver] + 3
				--car_shop.player_silver_coins[entity.driver] = car_shop.player_silver_coins[entity.driver] + 6
				--car_shop.player_bronze_coins[entity.driver] = car_shop.player_bronze_coins[entity.driver] + 10
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data.gold_coins = data.gold_coins + 6
					data.silver_coins = data.silver_coins + 12
					data.bronze_coins = data.bronze_coins + 20
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data.gold_coins = data.gold_coins + 3
					data.silver_coins = data.silver_coins + 6
					data.bronze_coins = data.bronze_coins + 10
				end
				meta:set_string("player_coins", minetest.serialize(data))
			else
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data = { gold_coins = 6, silver_coins = 12, bronze_coins = 20 }
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data = { gold_coins = 3, silver_coins = 6, bronze_coins = 10 }
				end
				meta:set_string("player_coins", minetest.serialize(data))

				--car_shop.player_gold_coins[entity.driver] = 3
				--car_shop.player_silver_coins[entity.driver] = 6
				--car_shop.player_bronze_coins[entity.driver] = 10
			end
			lib_mount.win_count = lib_mount.win_count + 1
			if core_game.player_count == 1 then
				core_game.players_that_won[0] = entity.driver

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
		elseif lib_mount.win_count == 2 then
			if core_game.player_count == 2 then
				core_game.players_that_won[1] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 2nd place! You won 5 silver coins and 8 bronze coins."))
			core_game.players_that_won[1] = entity.driver

			if data then--car_shop.player_gold_coins[entity.driver] ~= nil or car_shop.player_silver_coins[entity.driver] ~= nil or car_shop.player_bronze_coins[entity.driver] ~= nil then
				--car_shop.player_gold_coins[entity.driver] = car_shop.player_gold_coins[entity.driver] + 3
				--car_shop.player_silver_coins[entity.driver] = car_shop.player_silver_coins[entity.driver] + 6
				--car_shop.player_bronze_coins[entity.driver] = car_shop.player_bronze_coins[entity.driver] + 10
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data.silver_coins = data.silver_coins + 10
					data.bronze_coins = data.bronze_coins + 16
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data.silver_coins = data.silver_coins + 5
					data.bronze_coins = data.bronze_coins + 8
				end
				meta:set_string("player_coins", minetest.serialize(data))
			else
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data = { gold_coins = 0, silver_coins = 10, bronze_coins = 16 }
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data = { gold_coins = 0, silver_coins = 5, bronze_coins = 8 }
				end
				meta:set_string("player_coins", minetest.serialize(data))

				--car_shop.player_gold_coins[entity.driver] = 3
				--car_shop.player_silver_coins[entity.driver] = 6
				--car_shop.player_bronze_coins[entity.driver] = 10
			end
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 3 then
			if core_game.player_count == 3 then
				core_game.players_that_won[2] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 3rd place! You won 5 bronze coins."))
			core_game.players_that_won[2] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1

			if data then--car_shop.player_gold_coins[entity.driver] ~= nil or car_shop.player_silver_coins[entity.driver] ~= nil or car_shop.player_bronze_coins[entity.driver] ~= nil then
				--car_shop.player_gold_coins[entity.driver] = car_shop.player_gold_coins[entity.driver] + 3
				--car_shop.player_silver_coins[entity.driver] = car_shop.player_silver_coins[entity.driver] + 6
				--car_shop.player_bronze_coins[entity.driver] = car_shop.player_bronze_coins[entity.driver] + 10
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data.bronze_coins = data.bronze_coins + 10
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data.bronze_coins = data.bronze_coins + 5
				end
				meta:set_string("player_coins", minetest.serialize(data))
			else
				if minetest.get_modpath("premium") and minetest.check_player_privs(entity.driver, { has_premium = true }) then
					data = { gold_coins = 0, silver_coins = 0, bronze_coins = 10 }
					minetest.chat_send_player(entity.driver:get_player_name(), S("You won double coins for having premium!"))
				else
					data = { gold_coins = 0, silver_coins = 0, bronze_coins = 5 }
				end
				meta:set_string("player_coins", minetest.serialize(data))

				--car_shop.player_gold_coins[entity.driver] = 3
				--car_shop.player_silver_coins[entity.driver] = 6
				--car_shop.player_bronze_coins[entity.driver] = 10
			end
		elseif lib_mount.win_count == 4 then
			if core_game.player_count == 4 then
				core_game.players_that_won[3] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 4th place!"))
			core_game.players_that_won[3] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 5 then
			if core_game.player_count == 5 then
				core_game.players_that_won[4] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 5th place!"))
			core_game.players_that_won[4] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 6 then
			if core_game.player_count == 6 then
				core_game.players_that_won[5] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 6th place!"))
			core_game.players_that_won[5] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 7 then
			if core_game.player_count == 7 then
				core_game.players_that_won[6] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 7th place!"))
			core_game.players_that_won[6] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 8 then
			if core_game.player_count == 8 then
				core_game.players_that_won[7] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 8th place!"))
			core_game.players_that_won[7] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 9 then
			if core_game.player_count == 9 then
				core_game.players_that_won[8] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 9th place!"))
			core_game.players_that_won[8] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 10 then
			if core_game.player_count == 10 then
				core_game.players_that_won[9] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 10th place!"))
			core_game.players_that_won[9] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 11 then
			if core_game.player_count == 11 then
				core_game.players_that_won[10] = entity.driver
				minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))

				--core_game.game_started = false
				hud_fs.close_hud(entity.driver, "core_game:pending_race")
				for _,player in ipairs(minetest.get_connected_players()) do
					core_game.is_waiting_end[player] = false
					hud_fs.close_hud(player, "core_game:pending_race")
				end

				for _,name in pairs(core_game.players_on_race) do
					minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
				end

				minetest.after(0.1, function() -- Let's prevent small bugs :')
					core_game.player_count = 0
					for _,name in pairs(core_game.players_on_race) do
						minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
						core_game.player_lost(name)

						core_game.players_on_race = {}
					end
				end)
				return
			end
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in 11th place!"))
			core_game.players_that_won[10] = entity.driver
			lib_mount.win_count = lib_mount.win_count + 1
		elseif lib_mount.win_count == 12 then -- Here races end. Run end race code
			minetest.chat_send_player(entity.driver:get_player_name(), S("You are in the last place! You lost."))
			core_game.players_that_won[11] = entity.driver

			--core_game.game_started = false
			hud_fs.close_hud(entity.driver, "core_game:pending_race")
			for _,player in ipairs(minetest.get_connected_players()) do
				core_game.is_waiting_end[player] = false
				hud_fs.close_hud(player, "core_game:pending_race")
			end

			for _,name in pairs(core_game.players_on_race) do
				minetest.show_formspec(name:get_player_name(), "core_game:scoreboard", core_game.show_scoreboard(name))
			end

			minetest.after(0.1, function() -- Let's prevent small bugs :')
				core_game.player_count = 0
				for _,name in pairs(core_game.players_on_race) do
					minetest.chat_send_player(name:get_player_name(), S("Race ended! Heading back to the lobby..."))
					core_game.player_lost(name)

					core_game.players_on_race = {}
				end
			end)
		end
		--velo.y = 6 -- This will make the vehicle jump :D
		--entity.object:set_pos({x = -94.3, y = 3.5, z = 149.7})
		minetest.chat_send_player(entity.driver:get_player_name(), S("Game's up! You finished the race in @1 seconds.", core_game.count[entity.driver]))
	end

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
					lib_mount.detach(drvr, {x=0, y=0, z=0})
					drvr:set_velocity(new_velo)
					drvr:set_hp(drvr:get_hp() - intensity)
				end

				if entity.passenger then
					local pass = entity.passenger
					lib_mount.detach(pass, {x=0, y=0, z=0})
					pass:set_velocity(new_velo)
					pass:set_hp(pass:get_hp() - intensity)
				end

				if entity.passenger2 then
					local pass = entity.passenger2
					lib_mount.detach(pass, {x=0, y=0, z=0})
					pass:set_velocity(new_velo)
					pass:set_hp(pass:get_hp() - intensity)
				end

				if entity.passenger3 then
					local pass = entity.passenger3
					lib_mount.detach(pass, {x=0, y=0, z=0})
					pass:set_velocity(new_velo)
					pass:set_hp(pass:get_hp() - intensity)
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
