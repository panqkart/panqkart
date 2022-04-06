--vehicle_mash = {}
local drive = lib_mount.drive

function vehicle_mash.register_vehicle(name, def)
	minetest.register_entity(name, {
		terrain_type = def.terrain_type,
		collisionbox = def.collisionbox,
		can_fly = def.can_fly,
		can_go_down = def.can_go_down, -- Applies only when `can_fly` is enabled
		can_go_up = def.can_go_up, -- Applies only when `can_fly` is enabled
		player_rotation = def.player_rotation,
		driver_attach_at = def.driver_attach_at,
		driver_eye_offset = def.driver_eye_offset,
		driver_detach_pos_offset = def.driver_detach_pos_offset,
		number_of_passengers = def.number_of_passengers,
		passenger_attach_at = def.passenger_attach_at,
		passenger_eye_offset = def.passenger_eye_offset,
		passenger_detach_pos_offset = def.passenger_detach_pos_offset,

		passenger2_attach_at = def.passenger2_attach_at,
		passenger2_eye_offset = def.passenger2_eye_offset,
		passenger2_detach_pos_offset = def.passenger2_detach_pos_offset,

		passenger3_attach_at = def.passenger3_attach_at,
		passenger3_eye_offset = def.passenger3_eye_offset,
		passenger3_detach_pos_offset = def.passenger3_detach_pos_offset,

		enable_crash = def.enable_crash,
		visual = def.visual,
		mesh = def.mesh,
		textures = def.textures,
		tiles = def.tiles,
		visual_size = def.visual_size,
		stepheight = def.stepheight,

		max_speed_forward = def.max_speed_forward,
		max_speed_reverse = def.max_speed_reverse,
		max_speed_upwards = def.max_speed_upwards, -- Applies only when `can_fly` is enabled
		max_speed_downwards = def.max_speed_downwards, -- Applies only when `can_fly` is enabled

		accel = def.accel,
		braking = def.braking,
		turn_spd = def.turn_speed,
		drop_on_destroy = def.drop_on_destroy or {},
		driver = nil,
		passenge = nil,
		v = 0,
		v2 = 0,
		mouselook = false,
		physical = true,
		removed = false,
		offset = {x=0, y=0, z=0},
		owner = "",
		hp_min = def.hp_min,
		hp_max = def.hp_max,
		armor = def.armor,
		rpm_values = {{16, 16, .5}, {10, 10, .4}, {0, 5, .3}},
		on_rightclick = function(self, clicker)
			if not clicker or not clicker:is_player() then
				return
			end
			-- if there is already a driver
			if self.driver then
				-- if clicker is driver detach passengers and driver
				if clicker == self.driver then
					if self.passenger then
						lib_mount.detach(self.passenger, self.offset)
					end

					if self.passenger2 then
						lib_mount.detach(self.passenger2, self.offset)
					end

					if self.passenger3 then
						lib_mount.detach(self.passenger3, self.offset)
					end
					-- detach driver
					lib_mount.detach(self.driver, self.offset)
				-- if clicker is not the driver
				else
					-- if clicker is passenger
					-- detach passengers
					if clicker == self.passenger then
						lib_mount.detach(self.passenger, self.offset)

					elseif clicker == self.passenger2 then
						lib_mount.detach(self.passenger2, self.offset)

					elseif clicker == self.passenger3 then
						lib_mount.detach(self.passenger3, self.offset)
					-- if clicker is not passenger
					else
						-- attach passengers if possible
						if lib_mount.passengers[self.passenger] == self.passenger and self.number_of_passengers >= 1 then
							lib_mount.attach(self, clicker, true, 1)
						end
						if lib_mount.passengers[self.passenger2] == self.passenger2 and self.number_of_passengers >= 2 then
							lib_mount.attach(self, clicker, true, 2)
						end
						if lib_mount.passengers[self.passenger3] == self.passenger3 and self.number_of_passengers >= 3 then
							lib_mount.attach(self, clicker, true, 3)
						end
					end
				end
			-- if there is no driver
			else
				-- attach driver
				if self.owner == clicker:get_player_name() then
					lib_mount.attach(self, clicker, false, 0)
				end
			end
		end,
		on_activate = function(self, staticdata, dtime_s)
			if def.armor then
				self.object:set_armor_groups({fleshy = def.armor}) -- Set armor groups to vehicle
			else
				self.object:set_armor_groups({fleshy = 0}) -- Else, make vehicle immortal
			end
			if def.hp_min and def.hp_max then
				self.object:set_hp(math.random(def.hp_min, def.hp_max), "Set HP to vehicle")
			end

			--[[
			if self.driver then
				self.driver:set_armor_groups({immortal = 0, fleshy = self.driver:get_armor_groups()})
			-- Support for passengers
			elseif self.passenger then
				self.passenger:set_armor_groups({immortal = 0, fleshy = self.passenger:get_armor_groups()})
			elseif self.passenger2 then
				self.passenger2:set_armor_groups({immortal = 0, fleshy = self.passenger2:get_armor_groups()})
			elseif self.passenger3 then
				self.passenger3:set_armor_groups({immortal = 0, fleshy = self.passenger3:get_armor_groups()})
			end--]]

			local tmp = minetest.deserialize(staticdata)
			if tmp then
				for _,stat in pairs(tmp) do
					if _ == "owner" then print(stat) end
					self[_] = stat
				end
			end
			print("owner: ", self.owner)
			self.v2 = self.v
		end,
		get_staticdata = function(self)
			local tmp = {}
			for _,stat in pairs(self) do
				local t = type(stat)
				if  t ~= 'function' and t ~= 'nil' and t ~= 'userdata' then
					tmp[_] = self[_]
				end
			end
			return core.serialize(tmp)
		end,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
			if not puncher or not puncher:is_player() or self.removed or self.driver then
				return
			end
			local punchername = puncher:get_player_name()
			if self.owner == punchername or minetest.get_player_privs(punchername).protection_bypass then
			  self.removed = true
			  -- delay remove to ensure player is detached
			  minetest.after(0.1, function()
				self.object:remove()
			end)
			  puncher:get_inventory():add_item("main", self.name)
			end
		end,
		on_step = function(self, dtime, moveresult, ...)
			-- Automatically set `enable_crash` to true if there's no value found
			if def.enable_crash == nil then
				def.enable_crash = true
			end
			if moveresult.collides then
				for index, _ in pairs(moveresult.collisions) do
					if moveresult.collisions[index].type == "object" then
						self.object:move_to(vector.add(self.object:get_pos(), vector.multiply(vector.direction(moveresult.collisions[index].old_velocity,
							moveresult.collisions[index].new_velocity), 1.80))) -- Credits to appgurueu for helping!
					end
				end
			end
			drive(self, dtime, false, nil, nil, 0, def.can_fly, def.can_go_down, def.can_go_up, def.enable_crash, moveresult)
		end,
		on_death = function(self, killer)
			if self.driver then
				lib_mount.detach(self.driver, self.offset)
			end
			if self.passenger then
				lib_mount.detach(self.passenger, self.offset)
				self.passenger:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			end
			if self.passenger2 then
				lib_mount.detach(self.passenger2, self.offset)
				self.passenger2:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			end
			if self.passenger3 then
				lib_mount.detach(self.passenger3, self.offset)
				self.passenger3:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			end
		end
	})

	local can_float = false
	if def.terrain_type == 2 or def.terrain_type == 3 then
		can_float = true
	end

	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		wield_scale = def.wield_scale,
		liquids_pointable = can_float,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end
			local ent
			if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "liquid") == 0 then
				if def.terrain_type == 0 or def.terrain_type == 1 or def.terrain_type == 3 then
					pointed_thing.above.y = pointed_thing.above.y + def.onplace_position_adj
					ent = minetest.add_entity(pointed_thing.above, name)
				else
					return
				end
			else
				if def.terrain_type == 2 or def.terrain_type == 3 then
					pointed_thing.under.y = pointed_thing.under.y + 0.5
					ent = minetest.add_entity(pointed_thing.under, name)
				else
					return
				end

			end
			if ent:get_luaentity().player_rotation.y == 90 then
				ent:set_yaw(placer:get_look_horizontal())
			else
				ent:set_yaw(placer:get_look_horizontal() - math.pi/2)
			end
			ent:get_luaentity().owner = placer:get_player_name()
			itemstack:take_item()
			return itemstack
		end
	})

	if def.recipe then
		minetest.register_craft({
			output = name,
			recipe = def.recipe
		})
	end
end
