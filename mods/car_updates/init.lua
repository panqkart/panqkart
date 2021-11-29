car_updates = {}

car_updates.max_speed_forward = vehicle_mash.car01_def.max_speed_forward -- Library Mount will access this, so let's
																		 -- use the normal speed. When updating, this will change.
car_updates.max_speed_reverse = vehicle_mash.car01_def.max_speed_reverse -- Same here as above.
car_updates.accel = vehicle_mash.car01_def.accel -- Same here.

function car_updates.get_formspec(name)
    -- TODO: display whether the last guess was higher or lower
    local text = "Update car's speed forward to 16!"

    local formspec = {
        "formspec_version[4]",
        "size[6,3.476]",
        "label[0.375,0.5;", minetest.formspec_escape(text), "]",
        --"field[0.375,1.25;5.25,0.8;number;Speed;]",
        "button[1.5,2.3;3,0.8;update;Update now!",
    }

    -- table.concat is faster than string concatenation - `..`
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

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "car_updates:game" then
        return
    end

    if fields.update then
		local inv = player:get_inventory()
		if not inv:contains_item("main", "maptools:gold_coin 5") then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
			return
		else
			local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 5"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's speed to 16!")
			car_updates.max_speed_forward = 16--tonumber(fields.number)
		end
    end
end)
