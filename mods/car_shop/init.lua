car_shop = { }
car_shop.max_speed_forward = vehicle_mash.car01_def.max_speed_forward -- Library Mount will access this, so let's
																	  -- use the normal speed. When updating, this will change.
car_shop.max_speed_reverse = vehicle_mash.car01_def.max_speed_reverse -- Same here as above.
car_shop.hovercraft = {}

car_shop.hovercraft.max_speed_forward = vehicle_mash.hover_def.max_speed_forward
car_shop.hovercraft.max_speed_reverse = vehicle_mash.hover_def.max_speed_reverse

-- Upgrading your car's speed (CAR01)
local function update_speed(player, fields)
	local already_upgraded_reverse = false
	local already_upgraded_forward = false
	local inv = player:get_inventory()

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have the sufficient permissions to run this formspec.")
		return
	end

	if fields.update_speed then --forward_speed then
		if not inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_forward == true and not already_upgraded_reverse == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough silver coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_forward == true and not already_upgraded_reverse == true then
			local taken = inv:remove_item("main", ItemStack("maptools:silver_coin 10"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's forward speed to 16!")
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 13!")

			car_shop.max_speed_forward = 16
			car_shop.max_speed_reverse = 13
			already_upgraded_forward = true
			already_upgraded_reverse = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
	--[[elseif fields.reverse_speed then
		if not inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_reverse == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_reverse == true then
			local taken = inv:remove_item("main", ItemStack("maptools:silver_coin 10"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 13!")
			car_shop.max_speed_reverse = 13
			already_upgraded_reverse = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end--]]
	end

	-- Store information in the player's metadata
	local meta = player:get_meta()
	local data = { forward_speed = car_shop.max_speed_forward, reverse_speed = car_shop.max_speed_reverse }
	meta:set_string("speed", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("speed"))

	car_shop.max_speed_forward = vehicle_mash.car01_def.max_speed_forward
	car_shop.max_speed_reverse = vehicle_mash.car01_def.max_speed_reverse
	--minetest.chat_send_all(data.forward_speed)
end

-----------------------------
-- Buy Hovercraft vehicle --
-----------------------------
local function buy_hovercraft(player, fields)
	local already_bought = false
	local inv = player:get_inventory()

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have the sufficient permissions to run this formspec.")
		return
	end

	if fields.buy_hovercraft then
		if not inv:contains_item("main", "maptools:gold_coin 10") and not already_bought == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough gold coins to buy the Hovercraft")
			return
		elseif inv:contains_item("main", "maptools:gold_coin 10") and not already_bought == true then
			local taken = inv:remove_item("main", ItemStack("maptools:gold_coin 10"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully bought the Hovercraft vehicle!")
			already_bought = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already bought the Hovercraft!")
			return
		end
	end

	-- Store information in the player's metadata
	local meta = player:get_meta()
	local data = { bought_already = already_bought}
	meta:set_string("hovercraft_bought", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("hovercraft_bought"))
	--minetest.chat_send_all(data.forward_speed)
end

local function update_hover(player, fields)
	local already_upgraded_reverse = false
	local already_upgraded_forward = false
	local inv = player:get_inventory()

	if not minetest.check_player_privs(player:get_player_name(), {interact = true}) then
		minetest.chat_send_player(player:get_player_name(), "You don't have the sufficient permissions to run this formspec.")
		return
	end

	if fields.hover_speed then
		if not inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_forward == true and not already_upgraded_reverse == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough silver coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_forward == true and not already_upgraded_reverse == true then
			local taken = inv:remove_item("main", ItemStack("maptools:silver_coin 10"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's forward speed to 20!")
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 7!")

			car_shop.hovercraft.max_speed_reverse = 7
			already_upgraded_reverse = true
			car_shop.hovercraft.max_speed_forward = 20
			already_upgraded_forward = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end
	--[[elseif fields.hover_reverse then
		if not inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_reverse == true then
			minetest.chat_send_player(player:get_player_name(), "You don't have the enough silver coins to upgrade")
			return
		elseif inv:contains_item("main", "maptools:silver_coin 10") and not already_upgraded_reverse == true then
			local taken = inv:remove_item("main", ItemStack("maptools:silver_coin 10"))
			print("Took " .. taken:get_count())
			minetest.chat_send_player(player:get_player_name(), "Successfully updated car's reverse speed to 7!")
			car_shop.hovercraft.max_speed_reverse = 7
			already_upgraded_reverse = true
		else
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your car's speed!")
			return
		end--]]
	end

	-- Store information in the player's metadata
	local meta = player:get_meta()
	local data = { forward_speed = car_shop.hovercraft.max_speed_forward, reverse_speed = car_shop.hovercraft.max_speed_reverse }
	meta:set_string("hover_speed", minetest.serialize(data))
	data = minetest.deserialize(meta:get_string("hover_speed"))

	car_shop.hovercraft.max_speed_forward = vehicle_mash.hover_def.max_speed_forward
	car_shop.hovercraft.max_speed_reverse = vehicle_mash.hover_def.max_speed_reverse
	--minetest.chat_send_all(data.forward_speed)
end

-- Create upgrade car form
sfinv.register_page("car_shop:upgrade_car", {
    title = "Buy/upgrade car",
    get = function(self, player, context)
		local meta = player:get_meta()
		local data = minetest.deserialize(meta:get_string("speed"))

		local hover_bought = minetest.deserialize(meta:get_string("hovercraft_bought"))
		local hover_speed = minetest.deserialize(meta:get_string("hover_speed"))

		-- CAR01
		local forward_speed, reverse_speed
		if data then
			forward_speed = data.forward_speed
			reverse_speed = data.reverse_speed
		else
			forward_speed = vehicle_mash.car01_def.max_speed_forward
			reverse_speed = vehicle_mash.car01_def.max_speed_reverse
		end

		-- Hover speed
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
        formspec[#formspec + 1] = "Your CAR01 specs:,"
		formspec[#formspec + 1] = "Maximum speed forward: " .. minetest.formspec_escape(forward_speed) .. ","
		formspec[#formspec + 1] = "Maximum speed reverse: " .. minetest.formspec_escape(reverse_speed) .. ","

		-- Add current Hovercraft specs
		if hover_bought and hover_bought.bought_already == true then
       		formspec[#formspec + 1] = ",Your Hovercraft specs:,"
			formspec[#formspec + 1] = "Maximum speed forward: " .. minetest.formspec_escape(hover_forward) .. ","
			formspec[#formspec + 1] = "Maximum speed reverse: " .. minetest.formspec_escape(hover_reverse) .. ","
		end
		--formspec[#formspec + 1] = "Bronze coins needed: 20,"
		--formspec[#formspec + 1] = "Gold coins needed: 5]"

		--[[ FORWARD SPEED UPGRADES
		if data and not data.forward_speed == 16 then --or not data.reverse_speed == 13 then
			formspec[#formspec + 1] = "Silver coins needed: 10,"
			formspec[#formspec + 1] = "Forward speed already upgraded. Reverse ready to upgrade]"
        	formspec[#formspec + 1] = "button[0.1,3.3;2.25,1;forward_speed;Upgrade forward (CAR01)]"
        	--formspec[#formspec + 1] = "button[2.1,3.3;2.25,1;reverse_speed;Upgrade reverse (CAR01)]"
		-- REVERSE SPEED UPGRADES
		elseif data and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = "Silver coins needed: 10,"
			formspec[#formspec + 1] = "Reverse speed already upgraded. Forward ready to upgrade]"
        	formspec[#formspec + 1] = "button[0.1,3.3;2.25,1;reverse_speed;Upgrade reverse (CAR01)]"
		-- NO HOVERCRAFT WITH NO FORWARD SPEED MADE
		if not hover_bought.bought_already == true and data and not data.forward_speed == 16 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade CAR01: 10,"
			formspec[#formspec + 1] = ",Ready to upgrade CAR01 forward speed,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"
        	formspec[#formspec + 1] = "button[3.25,3.3;2.25,1;forward_speed;Upgrade forward (CAR01)]"
		-- NO HOVERCRAFT WITH NO REVERSE SPEED MADE
		elseif not hover_bought.bought_already == true and data and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade CAR01: 10,"
			formspec[#formspec + 1] = ",Ready to upgrade CAR01 reverse speed,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "button[3.25,3.3;2.25,1;reverse_speed;Upgrade reverse (CAR01)]"
		-- NO HOVERCRAFT WITH NO FORWARD/REVERSE SPEED UPDATES
		elseif not hover_bought.bought_already == true and data and not data.forward_speed == 16 and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade CAR01: 10,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "button[3.25,3.3;2.25,1;forward_speed;Upgrade forward (CAR01)]"
			formspec[#formspec + 1] = "button[0.1,3.3;2.25,2;reverse_speed;Upgrade reverse (CAR01)]"
		-- NO HOVERCRAFT WITH FORWARD UPDATES
		elseif not hover_bought.bought_already == true and data and data.forward_speed == 16 and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade CAR01: 10,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "button[3.25,3.3;2.25,1;reverse_speed;Upgrade reverse (CAR01)]"
		-- NO HOVERCRAFT WITH REVERSE UPDATES
		elseif not hover_bought.bought_already == true and data and data.reverse_speed == 13 and not data.forward_speed == 16 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade CAR01: 10,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "button[3.25,3.3;2.25,1;reverse_speed;Upgrade reverse (CAR01)]"
		-- NO HOVERCRAFT WITH REVERSE/FORWARD UPDATES
		elseif not hover_bought.bought_already == true and data and data.reverse_speed == 13 and data.forward_speed == 16 then
			formspec[#formspec + 1] = ",CAR01 forward/speed updates all done,"
			formspec[#formspec + 1] = "Gold coins needed to buy Hovercraft vehicle: 10]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;buy_hovercraft;Buy Hovercraft vehicle]"

		-- HOVERCRAFT, CAR01 WITH NO FORWARD UPDATES
		elseif hover_bought.bought_already == true and data and not data.forward_speed == 16 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade your vehicles: 10 for each,"
			formspec[#formspec + 1] = ",Ready to upgrade CAR01/Hovercraft forward speed,"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;forward_speed;Upgrade forward (CAR01)]"
			formspec[#formspec + 1] = "button[2.1,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			if not hover_speed.forward_speed == 20 then
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			end

		-- HOVERCRAFT, CAR01 WITH NO REVERSE UPDATES
		elseif hover_bought.bought_already == true and data and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade your vehicles: 10 for each,"
			formspec[#formspec + 1] = ",Ready to upgrade your vehicles' forward speed,"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;reverse_speed;Upgrade reverse (CAR01)]"
			if not hover_speed.reverse_speed == 7 then
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_forward;Upgrade reverse (Hover)]"
			end
		-- HOVERCRAFT, CAR01 WITH NO FORWARD/REVERSE SPEED UPDATES
		elseif hover_bought.bought_already == true and data and not data.forward_speed == 16 and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade your vehicles: 10 for each,"
			formspec[#formspec + 1] = ",Ready to upgrade your vehicles' forward/reverse speed,"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;reverse_speed;Upgrade reverse (CAR01)]"
			--formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
			formspec[#formspec + 1] = "button[0.1,3.3;3.25,2;forward_speed;Upgrade forward (CAR01)]"
			--formspec[#formspec + 1] = "button[3.25,3.3;3.25,2;hover_forward;Upgrade forward (Hover)]"
			if not hover_speed.forward_speed == 20 then
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			elseif hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
			else
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			end
		-- HOVERCRAFT, CAR01 WITH FORWARD UPDATES
		elseif hover_bought.bought_already == true and data and data.forward_speed == 16 and not data.reverse_speed == 13 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade your vehicles: 10 for each,"
			formspec[#formspec + 1] = ",Ready to upgrade your vehicles' forward speed,"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;reverse_speed;Upgrade reverse (CAR01)]"
			if not hover_speed.reverse_speed == 7 then
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
			end
		-- HOVERCRAFT, CAR01 WITH REVERSE UPDATES
		elseif hover_bought.bought_already == true and data and data.reverse_speed == 13 and not data.forward_speed == 16 then
			formspec[#formspec + 1] = ",Silver coins needed to upgrade your vehicles: 10 for each,"
			formspec[#formspec + 1] = ",Ready to upgrade your vehicles' forward speed,"
        	formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;forward_speed;Upgrade forward (CAR01)]"
			if not hover_speed.forward_speed == 20 then
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			end
		-- HOVERCRAFT, CAR01 WITH REVERSE/FORWARD UPDATES
		elseif hover_bought.bought_already == true and data and data.reverse_speed == 13 and data.forward_speed == 16 then
			formspec[#formspec + 1] = ",CAR01 forward/speed updates all done,"
			formspec[#formspec + 1] = "Silver coins needed to upgrade Hovercraft: 10]"
			if not hover_speed.forward_speed == 20 then
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			elseif hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
			else
				formspec[#formspec + 1] = "button[0.1,3.3;3.25,1;hover_reverse;Upgrade reverse (Hover)]"
				formspec[#formspec + 1] = "button[3.25,3.3;3.25,1;hover_forward;Upgrade forward (Hover)]"
			end

		elseif hover_bought.bought_already == true and not hover_forward == 20 or not hover_reverse == 7
			and data and data.forward_speed == 16 or data.reverse_speed == 13 then

			formspec[#formspec + 1] = ",You've already upgraded your CAR01 to the maximum speed,"
			formspec[#formspec + 1] = "Hovercraft already bought and ready to upgrade!]"

        	formspec[#formspec + 1] = "button[0.1,3.3;2.25,1;hover_forward;Upgrade forward (hover)]"
        	formspec[#formspec + 1] = "button[2.1,3.3;2.25,1;hover_reverse;Upgrade reverse (hover)]"
		end--]]
		-- No updates for CAR01, with no Hovercraft
		if not data and not hover_bought then--data and not data.forward_speed == 16 and not data.reverse_speed == 13
			--and not hover_bought.bought_already == true then
			formspec[#formspec + 1] = ",Silver coins needed: 10 for speed and 10 gold for Hovercraft,"
			formspec[#formspec + 1] = "Ready to upgrade your CAR01's speed and buy Hovercraft]"
			formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;    Upgrade speed (CAR01)]"
			formspec[#formspec + 1] = "button[3.50,3.3;3.60,1;buy_hovercraft;    Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
			formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
			formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- No updates for CAR01, with Hovercraft
		elseif not data and hover_bought and hover_bought.bought_already == true then --data and not data.forward_speed == 16 and not data.reverse_speed == 13
			--and hover_bought.bought_already == true then
				formspec[#formspec + 1] = ",Silver coins needed: 10 for CAR01 and 10 for Hovercraft,"
				formspec[#formspec + 1] = "Ready to upgrade your vehicles' speed]"
				formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;    Upgrade speed (CAR01)]"
				formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
				formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				if not hover_speed then--hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
					formspec[#formspec + 1] = "button[3.50,3.3;3.50,1;hover_speed;    Upgrade speed (Hover)]"
					formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
					formspec[#formspec + 1] = "image[3.75,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				end
		-- Updates for CAR01, with no Hovercraft
		elseif data and data.forward_speed == 16 and data.reverse_speed == 13
			and not hover_bought then--and not hover_bought.bought_already == true then
			formspec[#formspec + 1] = ",Silver coins needed: 10,"
			formspec[#formspec + 1] = "Ready to buy Hovercraft. All CAR01 updates done]"
			formspec[#formspec + 1] = "button[0.15,3.3;3.60,1;buy_hovercraft;Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "image[0.15,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- Updates for CAR01, with Hovercraft
		elseif data and data.forward_speed == 16 and data.reverse_speed == 13
			and hover_bought and hover_bought.bought_already == true then
				if not hover_speed then--not hover_speed.forward_speed == 20 and not hover_speed.reverse_speed == 7 then
					formspec[#formspec + 1] = ",Silver coins needed: 10,"
					formspec[#formspec + 1] = "Ready to upgrade your Hovercraft. All CAR01 updates done]"
					formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;hover_speed;Upgrade speed (Hover)]"
					formspec[#formspec + 1] = "image[0.15,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
					formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
				else
					formspec[#formspec + 1] = ",,Nothing to see here. All updates done!]"
				end
		-- No data found. The user can buy/upgrade
		elseif not data or not hover_bought or not hover_speed then
			formspec[#formspec + 1] = ",Silver coins needed: 10 for speed and 10 gold for Hovercraft,"
			formspec[#formspec + 1] = "Ready to upgrade your CAR01's speed and buy Hovercraft]"
        	formspec[#formspec + 1] = "button[0.15,3.3;3.50,1;update_speed;    Upgrade speed (CAR01)]"
			formspec[#formspec + 1] = "button[3.50,3.3;3.60,1;buy_hovercraft;    Buy Hovercraft vehicle]"
			formspec[#formspec + 1] = "image[0.15,3.43;0.65,0.65;inv_car_red.png]" -- CAR01 red
			formspec[#formspec + 1] = "image[0.40,3.33;0.5,0.5;car_shop_arrow_update.png]" -- Arrow update
			formspec[#formspec + 1] = "image[3.50,3.43;0.63,0.63;hovercraft_blue_inv.png]" -- Blue Hovercraft
		-- All updates done.
		else
			formspec[#formspec + 1] = ",,Nothing to see here. All updates done!]"
		end

        -- Wrap the formspec in sfinv's layout
        -- (ie: adds the tabs and background)
        return sfinv.make_formspec(player, context,
                table.concat(formspec, ""), false)
    end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.update_speed then
			update_speed(player, fields)

			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed forward (CAR01) for player " .. player:get_player_name() .. "!")
			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed reverse (CAR01) for player " .. player:get_player_name() .. "!")
		elseif fields.buy_hovercraft then
			buy_hovercraft(player, fields)
			minetest.log("action", "[CAR SHOP] Successfully bought Hovercraft car for player " .. player:get_player_name() .. "!")
		elseif fields.hover_speed then
			update_hover(player, fields)

			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed forward (Hovercraft) for player " .. player:get_player_name() .. "!")
			minetest.log("action", "[CAR SHOP] Successfully updated maximum speed reverse (Hovercraft) for player " .. player:get_player_name() .. "!")
		end
	end,
})


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
			car_shop.max_speed_forward = 16--tonumber(fields.number)
			already_upgraded = true
		elseif already_upgraded == true then
			minetest.chat_send_player(player:get_player_name(), "You already upgraded your speed to 16!")
		end
    end
end)
]]
