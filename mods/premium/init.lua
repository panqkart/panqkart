------------------
-- Privileges --
------------------
minetest.register_privilege("has_premium", {
    description = "The user has premium features. See /donate for more information.",
    give_to_singleplayer = false,
    give_to_admin = false,
})

----------------
-- Commands --
----------------

minetest.register_chatcommand("premium_house", {
	params = "<player>",
	description = "Teleport (the given player) to the premium/VIP house.",
    privs = {
        has_premium = true,
    },
    func = function(name, param)
		if param == "" then
			--name:set_pos() -- Not yet defined
			return true, "Successfully teleported to the premium/VIP house."
		end

		if param ~= "" and
				minetest.check_player_privs(name, { core_admin = true }) or param == name then
			name = param
		else
			return false, "You don't have sufficient permissions to run this command. Missing privileges: core_admin"
		end

		local player = minetest.get_player_by_name(name)
		if player then
			--param:set_pos() -- Not yet defined
			return true, "Successfully teleported " .. param .. " to the premium/VIP house."
		else
			return false, "Player " .. name .. " does not exist or is not online."
		end
	end,
})

minetest.register_chatcommand("fix_upgrades", {
	params = "<player>",
	description = "Fixes car acceleration and turn speed to the given player. Used for the premium features.",
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		if param == "" then
			return false, "Invalid player name. See /help fix_upgrades"
		end

		if param ~= "" and
				minetest.check_player_privs(name, { core_admin = true }) or param == name then
			name = param
		else
			return false, "You don't have sufficient permissions to run this command. Missing privileges: core_admin"
		end

		local player = minetest.get_player_by_name(name)
		if player then
			local meta = param:get_meta()
            local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))
            local car01 = minetest.deserialize(meta:get_string("speed"))

            if hover_speed then
                hover_speed.accel = vehicle_mash.hover_def.accel
                hover_speed.turn_speed = vehicle_mash.hover_def.turn_speed

                meta:set_string("hover_speed", minetest.serialize(hover_speed))
            elseif car01 then
                car01.accel = vehicle_mash.car01_def.accel
                car01.turn_speed = vehicle_mash.car01_def.turn_speed

                meta:set_string("speed", minetest.serialize(car01))
            else
                return false, "No upgrade data found for " .. param .. ". Aborting."
            end

			return true, "Successfully updated acceleration/turn speed for player " .. param .. "."
		else
			return false, "Player " .. name .. " does not exist or is not online."
		end
	end,
})