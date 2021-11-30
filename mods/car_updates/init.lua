car_updates = {}

car_updates.max_speed_forward = vehicle_mash.car01_def.max_speed_forward -- Library Mount will access this, so let's
																		 -- use the normal speed. When updating, this will change.
car_updates.max_speed_reverse = vehicle_mash.car01_def.max_speed_reverse -- Same here as above.
car_updates.accel = vehicle_mash.car01_def.accel -- Same here.

local already_upgraded_reverse = false
local already_upgraded_forward = false

function car_updates.get_formspec(name)
    local text = "Update car's speed forward to 16!"

    local formspec = {
        "formspec_version[4]",
        "size[6,3.476]",
        "label[0.375,0.5;", minetest.formspec_escape(text), "]",
        --"field[0.375,1.25;5.25,0.8;number;Speed;]",
        "button[1.5,2.3;3,0.8;button;Update now!",
    }

    return table.concat(formspec, "")
end

function car_updates.show_to(name)
    minetest.show_formspec(name, "car_updates:game", car_updates.get_formspec(name))
end

minetest.register_chatcommand("upgrade_speed", {
    func = function(name)
        car_updates.show_to(name)
    end,
})

local function update_speed(player, fields)
	local inv = player:get_inventory()
	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have the sufficient permissions to run this formspec.")
		return
	end

	if fields.forward_speed then
		if not inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_forward == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_forward == true then
			local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's forward speed to 16!")
			car_updates.max_speed_forward = 16
			already_upgraded_forward = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
	elseif fields.reverse_speed then
		if not inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_reverse == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_reverse == true then
			local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 13!")
			car_updates.max_speed_reverse = 13
			already_upgraded_reverse = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
	end

	--[[if not inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_forward == true then
		minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
		return

	elseif not inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_reverse == true then
		minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
		return

	elseif inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_forward == true then
		if speed_type == 1 then
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
		local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
		print("Took " .. taken:get_count())
		if speed_type == 0 then -- Forward
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's forward speed to 16!")
			car_updates.max_speed_forward = 16
			already_upgraded_forward = true
		end

	elseif inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded_reverse == true then
		if speed_type == 0 then
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
		local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
		print("Took " .. taken:get_count())
		if speed_type == 1 then -- Reverse
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 13!")
			car_updates.max_speed_reverse = 13
			already_upgraded_reverse = true
		end
		--already_upgraded = true
	else--if already_upgraded_reverse == true or already_upgraded_forward == true then
		minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
		return
	end--]]

	-- Store information in the player's metadata

	local meta = player:get_meta()
	local data = { forward_speed = car_updates.max_speed_forward, reverse_speed = car_updates.max_speed_reverse }
	meta:set_string("speed", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("speed"))
	--minetest.chat_send_all(data.forward_speed)
end

minetest.register_on_joinplayer(function(player)
	--[[local meta = player:get_meta()
	local data = minetest.deserialize(meta:get_string("speed"))
	if data then
		car_updates.max_speed_forward = data.forward_speed
		minetest.chat_send_all(car_updates.max_speed_forward)
	end--]]
end)

sfinv.register_page("car_updates:upgrade_car", {
    title = "Upgrade car",
    get = function(self, player, context)
		local meta = player:get_meta()
		local data = minetest.deserialize(meta:get_string("speed"))

		local forward_speed, reverse_speed
		if data then
			forward_speed = data.forward_speed
			reverse_speed = data.reverse_speed
		else
			forward_speed = vehicle_mash.car01_def.max_speed_forward
			reverse_speed = vehicle_mash.car01_def.max_speed_reverse
		end
        --local players = {}
        --context.myadmin_players = players

        -- Using an array to build a formspec is considerably faster
        local formspec = {
            "textlist[0.1,0.1;7.8,3;current_specs;"
        }

        -- Add current car specs
        formspec[#formspec + 1] = "Current car specs:,"
		formspec[#formspec + 1] = "Maximum speed forward: " .. minetest.formspec_escape(forward_speed) .. ","
		formspec[#formspec + 1] = "Maximum speed reverse: " .. minetest.formspec_escape(reverse_speed) .. "]"

        -- Upgrade buttons
        formspec[#formspec + 1] = "button[0.1,3.3;2,1;forward_speed;Upgrade forward]"
        formspec[#formspec + 1] = "button[2.1,3.3;2,1;reverse_speed;Upgrade reverse]"

        -- Wrap the formspec in sfinv's layout
        -- (ie: adds the tabs and background)
        return sfinv.make_formspec(player, context,
                table.concat(formspec, ""), false)
    end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.forward_speed then
			update_speed(player, fields)
			minetest.log("action", "[CAR UPDATES] Successfully updated maximum speed forward for player " .. player:get_player_name() .. "!")
		elseif fields.reverse_speed then
			update_speed(player, fields)
			minetest.log("action", "[CAR UPDATES] Successfully updated maximum speed reverse for player " .. player:get_player_name() .. "!")
		end
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "car_updates:game" then
        return
    end

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have the sufficient permissions to run this formspec.")
		return
	end

    if fields.button then
		local inv = player:get_inventory()
		if not inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:gold_coin 5") and not already_upgraded == true then
			local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's speed to 16!")
			car_updates.max_speed_forward = 16--tonumber(fields.number)
			already_upgraded = true
		elseif already_upgraded == true then
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your speed to 16!")
		end
    end
end)
