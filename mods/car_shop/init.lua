--[[
In-game shop to upgrade your vehicles. Part of the PanqKart game.

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

car_shop = { }

car_shop.player_gold_coins = { }
car_shop.player_silver_coins = { }
car_shop.player_bronze_coins = { }

local use_hover = { }

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

if minetest.settings:get_bool("enable_car_shop") == nil then
	minetest.settings:set_bool("enable_car_shop", true) -- Enable car shop by default if no value initialized
elseif minetest.settings:get_bool("enable_car_shop") == false then
	minetest.log("action", "[RACING GAME] Car shop is disabled. Not initializing.")
	return
end

----------------------
-- Local functions --
----------------------

local function confirm_upgrade(name, is_hover)
	local text, formspec
	local text2 = S("Your car's acceleration and\nturn speed will be decreased.")
	if is_hover == false then
		text = S("Are you sure you want\nto upgrade your CAR01?")
		formspec = {
			"formspec_version[4]",
			"size[7,4.5]",
			"label[1.25,0.5;", minetest.formspec_escape(text), "]",
			"label[1.25,2;", minetest.formspec_escape(text2), "]",
			"button_exit[0.3,3.13;3,0.8;yes;Yes]",
			"button_exit[3.8,3.13;3,0.8;no;No]"
		}
	elseif is_hover == true then
		text = S("Are you sure you want to\nupgrade your Hovercraft?")
		formspec = {
			"formspec_version[4]",
			"size[7,4.5]",
			"label[1.25,0.5;", minetest.formspec_escape(text), "]",
			"label[1.25,2;", minetest.formspec_escape(text2), "]",
			"button_exit[0.3,3.13;3,0.8;yes_hover;" .. S("Yes") .. "]",
			"button_exit[3.8,3.13;3,0.8;no_hover;" .. S("No") .. "]"
		}
	elseif is_hover == "buy" then
		text = S("Are you sure you want\nto buy the Hovercraft?")
		formspec = {
			"formspec_version[4]",
			"size[7,3.75]",
			"label[1.75,0.5;", minetest.formspec_escape(text), "]",
			"button_exit[0.3,2.3;3,0.8;yes_buy;" .. S("Yes") .. "]",
			"button_exit[3.8,2.3;3,0.8;no_buy;" .. S("No") .. "]",
		}
	end

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Update CAR01's speed for the specified player
--- @param player string the player that will receive the update
--- @param fields table the provided formspec fields
--- @returns void
local function update_speed(player, fields)
	local already_upgraded = false
	local max_speed_forward, max_speed_reverse

	local turn_speed = vehicle_mash.car01_def.turn_speed
	local accel = vehicle_mash.car01_def.accel
	--local inv = player:get_inventory()

	local meta = player:get_meta()
	local coins = minetest.deserialize(meta:get_string("player_coins"))

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), S("You don't have sufficient permissions to run this formspec."))
		return
	end

	if fields.yes or fields.update_speed then --forward_speed then
		if coins and coins.silver_coins < 10 or not coins then
			minetest.chat_send_player(player:get_player_name(), S("You don't have the enough silver coins to upgrade"))
			return
		elseif coins and coins.silver_coins >= 10 and not already_upgraded == true then
			minetest.chat_send_player(player:get_player_name(), S("Successfully updated car's forward speed to 13!"))
			minetest.chat_send_player(player:get_player_name(), S("Successfully updated car's reverse speed to 10!"))

			max_speed_forward = 13
			max_speed_reverse = 10

			turn_speed = 2.5
			accel = 1.75
			already_upgraded = true -- luacheck: no unused

			coins.silver_coins = coins.silver_coins - 10
			meta:set_string("player_coins", minetest.serialize(coins))
		else
			minetest.chat_send_player(player:get_player_name(), S("You already upgraded your car's speed!"))
			return
		end
	end

	-- Store information in the player's metadata
	local data = { forward_speed = max_speed_forward, reverse_speed = max_speed_reverse, turn_speed = turn_speed, accel = accel }
	meta:set_string("speed", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("speed")) -- luacheck: no unused
end

--- @brief Buy the Hovercraft vehicle for the specified player.
--- The player requires 5 gold coins for that. To obtain coins, you need to win a race.
--- @param player string the player that will receive the Hovercraft
--- @param fields table the provided formspec fields
--- @returns void
local function buy_hovercraft(player, fields)
	local already_bought = false

	local meta = player:get_meta()
	local coins = minetest.deserialize(meta:get_string("player_coins"))

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), S("You don't have sufficient permissions to run this formspec."))
		return
	end

	if fields.buy_hovercraft or fields.yes_buy then
		if coins and coins.gold_coins < 5 then
			minetest.chat_send_player(player:get_player_name(), S("You don't have the enough gold coins to buy the Hovercraft"))
			return
		elseif coins and coins.gold_coins >= 5 and not already_bought == true then
			minetest.chat_send_player(player:get_player_name(), S("Successfully bought the Hovercraft vehicle!"))
			already_bought = true

			coins.gold_coins = coins.gold_coins - 5
			meta:set_string("player_coins", minetest.serialize(coins))
		else
			minetest.chat_send_player(player:get_player_name(), S("You already bought the Hovercraft!"))
			return
		end
	end

	-- Store information in the player's metadata
	local data = { bought_already = already_bought }
	meta:set_string("hovercraft_bought", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("hovercraft_bought")) -- luacheck: no unused
	--minetest.chat_send_all(data.forward_speed)
end

--- @brief Update Hovercraft speed for the specified player
--- @param player string the player that will receive the update
--- @param fields table the provided formspec fields
--- @returns void
local function update_hover(player, fields)
	local max_speed_forward, max_speed_reverse

	local turn_speed = vehicle_mash.hover_def.turn_speed
	local accel = vehicle_mash.hover_def.accel

	local meta = player:get_meta()
	local coins = minetest.deserialize(meta:get_string("player_coins"))

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), S("You don't have sufficient permissions to run this formspec."))
		return
	end

	if fields.hover_speed or fields.yes_hover then
		if coins and coins.silver_coins < 10 or not coins then
			minetest.chat_send_player(player:get_player_name(), S("You don't have the enough silver coins to upgrade"))
			return
		elseif coins and coins.silver_coins >= 10 then
			minetest.chat_send_player(player:get_player_name(), S("Successfully updated car's forward speed to 15!"))
			minetest.chat_send_player(player:get_player_name(), S("Successfully updated car's reverse speed to 8!"))

			max_speed_reverse = 8
			max_speed_forward = 15

			turn_speed = 1.5
			accel = 2

			coins.silver_coins = coins.silver_coins - 10
			meta:set_string("player_coins", minetest.serialize(coins))
		else
			minetest.chat_send_player(player:get_player_name(), S("You already upgraded your car's speed!"))
			return
		end
	end

	-- Store information in the player's metadata
	local data = { forward_speed = max_speed_forward, reverse_speed = max_speed_reverse,
		turn_speed = turn_speed, accel = accel }
	meta:set_string("hover_speed", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("hover_speed")) -- luacheck: no unused
end

-- Create upgrade car form
sfinv.register_page("car_shop:upgrade_car", {
    title = "Buy/upgrade car",
    get = function(self, player, context)
		local meta = player:get_meta()
		local data = minetest.deserialize(meta:get_string("speed"))

		local hover_bought = minetest.deserialize(meta:get_string("hovercraft_bought"))
		local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))
		local coins = minetest.deserialize(meta:get_string("player_coins"))

		-- CAR01
		local forward_speed, reverse_speed
		if data then
			forward_speed = data.forward_speed
			reverse_speed = data.reverse_speed
		else
			forward_speed = vehicle_mash.car01_def.max_speed_forward
			reverse_speed = vehicle_mash.car01_def.max_speed_reverse
		end

		-- Hovercraft
		local hover_forward, hover_reverse
		if hover_speed then
			hover_forward = hover_speed.forward_speed
			hover_reverse = hover_speed.reverse_speed
		else
			hover_forward = vehicle_mash.hover_def.max_speed_forward
			hover_reverse = vehicle_mash.hover_def.max_speed_reverse
		end

        -- Using an array to build a formspec is considerably faster
        local formspec = {
            "textlist[0.1,0.1;7.8,3;current_specs;"
        }

        -- Add current CAR01 specs
        formspec[#formspec + 1] = S("Your CAR01 specs:") .. ","
		formspec[#formspec + 1] = S("Maximum speed forward: @1", minetest.formspec_escape(forward_speed)) .. ","
		formspec[#formspec + 1] = S("Maximum speed reverse: @1", minetest.formspec_escape(reverse_speed)) .. ",,"

		-- Add current Hovercraft specs
		if hover_bought and hover_bought.bought_already == true then
			formspec[#formspec + 1] = S("Your Hovercraft specs:") .. ","
			formspec[#formspec + 1] = S("Maximum speed forward: @1", minetest.formspec_escape(hover_forward)) .. ","
			formspec[#formspec + 1] = S("Maximum speed reverse: @1", minetest.formspec_escape(hover_reverse)) .. ",,"
		end

		if coins then
			if coins.bronze_coins then --car_shop.player_bronze_coins[player] then
				formspec[#formspec + 1] = S("Bronze coins: @1", minetest.formspec_escape(coins.bronze_coins)) .. ","
			if coins.silver_coins then--car_shop.player_silver_coins[player] then
				formspec[#formspec + 1] = S("Silver coins: @1", minetest.formspec_escape(coins.silver_coins)) .. ","
			end
			if coins.gold_coins then--car_shop.player_gold_coins[player] then
				formspec[#formspec + 1] = S("Gold coins: @1", minetest.formspec_escape(coins.gold_coins)) .. ","
			end
			else
				formspec[#formspec + 1] = S("You currently have no coins.\nWin a race in the top 3 places to get coins!") .. ","
			end
		else
			formspec[#formspec + 1] = S("You currently have no coins.\nWin a race in the top 3 places to get coins!") .. ","
		end

		-- No updates for CAR01, with no Hovercraft
		if not data and not hover_bought then--data and not data.forward_speed == 16 and not data.reverse_speed == 13
			--and not hover_bought.bought_already == true then
			formspec[#formspec + 1] = "," .. S("Silver coins needed: 10 for speed and 5 gold for Hovercraft") .. ","
			formspec[#formspec + 1] = S("Ready to upgrade your CAR01's speed and buy Hovercraft") .. "]"
			formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;" .. S("Upgrade speed (CAR01)") .. "]"
			formspec[#formspec + 1] = "button[3.50,3.3;3.60,1;buy_hovercraft;" .. S("Buy Hovercraft vehicle") .. "]"
			--formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
			--formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
			--formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- No updates for CAR01, with Hovercraft
		elseif not data and hover_bought and hover_bought.bought_already == true then --data and not data.forward_speed == 16 and not data.reverse_speed == 13
			--and hover_bought.bought_already == true then
				formspec[#formspec + 1] = "," .. S("Silver coins needed: 10 for CAR01 and 10 for Hovercraft") .. ","
				formspec[#formspec + 1] = S("Ready to upgrade your vehicles' speed") .. "]"
				formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;" .. S("Upgrade speed (CAR01)") .. "]"
				--formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
				--formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				if not hover_speed then--hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
					formspec[#formspec + 1] = "button[3.50,3.3;3.50,1;hover_speed;" .. S("Upgrade speed (Hover)") .. "]"
					--formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
					--formspec[#formspec + 1] = "image[3.75,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				end
		-- Updates for CAR01, with no Hovercraft
		elseif data and data.forward_speed == 13 and data.reverse_speed == 10
			and not hover_bought then--and not hover_bought.bought_already == true then
			formspec[#formspec + 1] = "," .. S("Gold coins needed: 5") .. ","
			formspec[#formspec + 1] = S("Ready to buy Hovercraft. All CAR01 updates done") .. "]"
			formspec[#formspec + 1] = "button[0.15,3.3;3.60,1;buy_hovercraft;" .. S("Buy Hovercraft vehicle") .. "]"
			--formspec[#formspec + 1] = "image[0.15,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- Updates for CAR01, with Hovercraft
		elseif data and data.forward_speed == 13 and data.reverse_speed == 10
			and hover_bought and hover_bought.bought_already == true then
				if not hover_speed then--not hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
					formspec[#formspec + 1] = "," .. S("Silver coins needed: 10") .. ","
					formspec[#formspec + 1] = S("Ready to upgrade your Hovercraft. All CAR01 updates done") .. "]"
					formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;hover_speed;" .. S("Upgrade speed (Hover)") .. "]"
					--formspec[#formspec + 1] = "image[0.15,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
					--formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				else
					formspec[#formspec + 1] = ",," .. S("Nothing to see here. All updates done!") .. "]"
				end
		-- No data found. The user can buy/upgrade
		elseif not data or not hover_bought or not hover_speed then
			formspec[#formspec + 1] = "," .. S("Silver coins needed: 10 for speed and 5 gold for Hovercraft") .. ","
			formspec[#formspec + 1] = S("Ready to upgrade your CAR01's speed and buy Hovercraft") .. "]"
			formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;" .. S("Upgrade speed (CAR01)") .. "]"
			formspec[#formspec + 1] = "button[3.50,3.3;3.60,1;buy_hovercraft;" .. S("Buy Hovercraft vehicle") .. "]"
			--formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
			--formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
			--formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- All updates done.
		else
			formspec[#formspec + 1] = ",," .. S("Nothing to see here. All updates done!") .. "]"
		end

        return sfinv.make_formspec(player, context,
                table.concat(formspec, ""), false)
    end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.update_speed then
			use_hover[player] = false

			--local inv = player:get_inventory()
			local meta = player:get_meta()
			local coins = minetest.deserialize(meta:get_string("player_coins"))

			if coins and coins.silver_coins >= 10 then--inv:contains_item("main", "maptools:silver_coin 10") then
				minetest.show_formspec(player:get_player_name(), "car_shop:confirm_upgrade", confirm_upgrade(player, false))
			elseif coins and coins.silver_coins < 10 then
				update_speed(player, fields)
			end
		elseif fields.buy_hovercraft then
			--local inv = player:get_inventory()
			local meta = player:get_meta()
			local coins = minetest.deserialize(meta:get_string("player_coins"))

			if coins and coins.gold_coins >= 5 then--inv:contains_item("main", "maptools:gold_coin 5") then
				minetest.show_formspec(player:get_player_name(), "car_shop:confirm_upgrade", confirm_upgrade(player, "buy"))
			elseif coins and coins.gold_coins < 5 then
				buy_hovercraft(player, fields)
			end
			minetest.log("action", "[CAR SHOP] Successfully bought Hovercraft car for player " .. player:get_player_name() .. "!")
		elseif fields.hover_speed then
			use_hover[player] = true

			--local inv = player:get_inventory()
			local meta = player:get_meta()
			local coins = minetest.deserialize(meta:get_string("player_coins"))

			if coins and coins.silver_coins >= 10 then--inv:contains_item("main", "maptools:silver_coin 10") then
				minetest.show_formspec(player:get_player_name(), "car_shop:confirm_upgrade", confirm_upgrade(player, true))
			elseif coins and coins.silver_coins < 10 then
				update_hover(player, fields)
			end

			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed forward (Hovercraft) for player " .. player:get_player_name() .. "!")
			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed reverse (Hovercraft) for player " .. player:get_player_name() .. "!")
		end
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "car_shop:confirm_upgrade" then
        return
    end

    if fields.yes or fields.yes_hover then
		if use_hover[player] == true then
			update_hover(player, fields)

			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed forward (Hovercraft) for player " .. player:get_player_name() .. "!")
			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed reverse (Hovercraft) for player " .. player:get_player_name() .. "!")
		else
			update_speed(player, fields)

			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed forward (CAR01) for player " .. player:get_player_name() .. "!")
			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed reverse (CAR01) for player " .. player:get_player_name() .. "!")
		end
	elseif fields.yes_buy then
		buy_hovercraft(player, fields)
		minetest.log("action", "[CAR SHOP] Successfully bought Hovercraft car for player " .. player:get_player_name() .. "!")
	elseif fields.no or fields.no_hover or fields.no_buy then
		sfinv.set_page(player, "car_shop:upgrade_car")
		return true
    end
end)


--[[ Old/unused code

local function update_speed(player, fields)
	local inv = player:get_inventory()

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
			car_shop.max_speed_forward = 16
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
			car_shop.max_speed_reverse = 13
			already_upgraded_reverse = true
		end
		--already_upgraded = true
	else--if already_upgraded_reverse == true or already_upgraded_forward == true then
		minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
		return
	end--] ]
end

function car_shop.get_formspec(name)
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

function car_shop.show_to(name)
    minetest.show_formspec(name, "car_shop:game", car_shop.get_formspec(name))
end

minetest.register_chatcommand("upgrade_speed", {
    func = function(name)
        car_shop.show_to(name)
    end,
})

minetest.register_on_joinplayer(function(player)
	--[[local meta = player:get_meta()
	local data = minetest.deserialize(meta:get_string("speed"))
	if data then
		car_shop.max_speed_forward = data.forward_speed
		minetest.chat_send_all(car_shop.max_speed_forward)
	end--] ]
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "car_shop:game" then
        return
    end

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have sufficient permissions to run this formspec.")
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
			car_shop.max_speed_forward = 16--tonumber(fields.number)
			already_upgraded = true
		elseif already_upgraded == true then
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your speed to 16!")
		end
    end
end)
]]
