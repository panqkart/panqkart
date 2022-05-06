local global_fields = {}
local players = {}

----------------------
-- Local functions --
----------------------
local function show_formspec(meta)
	local text = "Choose the options here."
	local formspec = {
		"formspec_version[4]",
		"size[7,5]",
		"label[1.25,0.5;", minetest.formspec_escape(text), "]",
		"field[0.375,1.2;5.25,0.8;bronze;Bronze coins;${bronze}]",
		"field[0.375,2.13;5.25,0.8;silver;Silver coins;${silver}]",
		"field[0.375,3;5.25,0.8;gold;Gold coins;${gold}]",
		"button_exit[4,3.90;3,0.8;apply;Apply changes]",
		"checkbox[0.375,4.5;staff_coins;Give coins to staff;", (meta:get_int("staff_coins") == 1) and "true" or "false", "]"
	}

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

-------------
-- Nodes --
-------------

minetest.register_node("coin_chest:chest", {
	description = "Coin chest",
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_front.png",
		"default_chest_side.png"
	},
	sounds = default.node_sound_wood_defaults(),
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	drop = "",
	on_place = function(itemstack, placer, pointed_thing)
        if not minetest.check_player_privs(placer, { core_admin = true }) then
            return false, "You don't have the sufficient permissions to place this node. Missing privileges: core_admin"
        end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)

		local player_meta = clicker:get_meta()
		local coins = minetest.deserialize(player_meta:get_string("player_coins"))
		local playerlist = minetest.deserialize(meta:get_string("playerlist"))
		if not minetest.check_player_privs(clicker, { core_admin = true }) then
			if not global_fields.bronze then
				meta:set_string("formspec", "")

				-- Start: special thanks to neinwhal for building the code!
				if playerlist then
					for _, names in ipairs(playerlist) do
						if clicker:get_player_name() == names then
							minetest.chat_send_player(clicker:get_player_name(), "You have already got the coins from this chest.")
							return
						end
					end
				end

				-- if no name found, store new value
				playerlist[#playerlist + 1] = clicker:get_player_name()
				meta:set_string("playerlist", minetest.serialize(playerlist))
				-- End: special thanks to neinwhal for building the code!

				minetest.chat_send_player(clicker:get_player_name(), "You don't have the sufficient permissions to open this chest. Missing privileges: core_admin")
            	return--false, "You don't have the sufficient permissions to open this chest. Missing privileges: core_admin"
			else
				-- Start: special thanks to neinwhal for building the code!
				if playerlist then
					for _, names in ipairs(playerlist) do
						if clicker:get_player_name() == names then
							minetest.chat_send_player(clicker:get_player_name(), "You have already got the coins from this chest.")
							return
						end
					end
				end

				-- if no name found, store new value
				playerlist[#playerlist + 1] = clicker:get_player_name()
				meta:set_string("playerlist", minetest.serialize(playerlist))
				-- End: special thanks to neinwhal for building the code!

				meta:set_string("formspec", "")
				if coins then
					coins.bronze_coins = coins.bronze_coins + tonumber(global_fields.bronze)
					coins.silver_coins = coins.silver_coins + tonumber(global_fields.silver)
					coins.gold_coins = coins.gold_coins + tonumber(global_fields.gold)

					player_meta:set_string("player_coins", minetest.serialize(coins))
				else
					coins = { bronze_coins = global_fields.bronze, silver_coins = global_fields.silver, gold_coins = global_fields.gold }
					player_meta:set_string("player_coins", minetest.serialize(coins))
				end
				minetest.chat_send_player(clicker:get_player_name(), "You got " .. global_fields.bronze .. " bronze coins, " ..
					global_fields.silver .. " silver coins, and " .. global_fields.gold .. " coins!")
			end
		else
			meta:set_string("formspec", show_formspec(meta))
        end
	end,
	--[[on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		if meta and minetest.check_player_privs(puncher, { core_admin = true }) and meta:get_int("staff_coins") == 1 then
			meta_checks(puncher, pos)
		end
	end,--]]
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest");
		meta:set_string("formspec", show_formspec(meta))
		meta:set_string("playerlist", minetest.serialize({}))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		--global_fields = fields -- Set values as fast as possible for the formspec checkbox (see code above)
		if fields.apply then
			if fields.bronze == "" or fields.bronze == "0" or fields.silver == "" or
				fields.silver == "0" or fields.gold == "" or fields.gold == "0" then
				minetest.chat_send_player(sender:get_player_name(), "Please specify a valid value different than zero.")
				return
			end

			meta:set_string("bronze", fields.bronze)
			meta:set_string("silver", fields.silver)
			meta:set_string("gold", fields.gold)

			minetest.chat_send_player(sender:get_player_name(), "Successfully updated/set coin chest!")
			meta:set_string("formspec", show_formspec(meta))
			--minetest.log("info", fields.staff_coins)
		end
		if fields.staff_coins then
			--[[if my_boolean[sender] == true then
				my_boolean[sender] = false
				meta:set_int("staff_coins", (my_boolean[sender] == true) and 1 or 0)
				minetest.chat_send_all((meta:get_int("staff_coins") == 1) and "true" or "false")
				return
			end
			my_boolean[sender] = true
			meta:set_int("staff_coins", (my_boolean[sender] == true) and 1 or 0)
			minetest.chat_send_all((meta:get_int("staff_coins") == 1) and "true" or "false")
			if my_boolean[sender] == true then
				my_boolean[sender] = false
                meta:set_int("staff_coins", 0)
                minetest.chat_send_all((meta:get_int("staff_coins") == 1) and "true" or "false")
                return
            end
			my_boolean[sender] = true
            meta:set_int("staff_coins", 1)
            minetest.chat_send_all((meta:get_int("staff_coins") == 1) and "true" or "false")--]]

			meta:set_int("staff_coins", (fields.staff_coins == "true") and 1 or 0)
		end
		global_fields = fields
	end,
})
