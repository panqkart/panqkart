--[[
Adds a chest that contains in-game coins for the cars. Requires the `car_shop` mod.

Copyright (C) 2022-2023 David Leal (halfpacho@gmail.com)
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

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

----------------------
-- Local functions --
----------------------
local function show_formspec(meta)
	local formspec = {
		"formspec_version[5]",
		"size[7,5]",
		"label[1.25,0.5;", minetest.formspec_escape(S("Customize the coin chest")), "]",
		"field[0.375,1.2;5.25,0.8;bronze;" .. S("Bronze coins") .. ";${bronze}]",
		"field[0.375,2.13;5.25,0.8;silver;" .. S("Silver coins") .. ";${silver}]",
		"field[0.375,3;5.25,0.8;gold;" .. S("Gold coins") .. ";${gold}]",
		"button_exit[4,3.90;3,0.8;apply;" .. S("Apply changes") .. "]",
		"checkbox[0.375,4.5;staff_coins;" .. S("Give coins to staff (left-click to take coins)") .. ";", (meta:get_int("staff_coins") == 1) and "true" or "false", "]" -- Special thanks to LandarVangan/LoneWolfHT for helping!
	}

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

--- @brief Verifies if the coins are set or not.
--- @param meta string the metadata to be used
--- @return false if one or more coins are not set
local function no_coins(meta)
	if meta:get_string("bronze") == "" or meta:get_string("silver") == ""
		or meta:get_string("gold") == "" then
			return true
		end
	return false
end

-------------
-- Nodes --
-------------

minetest.register_node("pk_chest:chest", {
	description = S("Coin chest"),
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_front.png"
	},
	sounds = default.node_sound_wood_defaults(),
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	drop = "",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	on_place = function(itemstack, placer, pointed_thing)
        if not minetest.check_player_privs(placer, { core_admin = true }) then
            return false, S("You don't have sufficient permissions to place this node. Missing privileges: core_admin")
        end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		if meta:get_string("bronze") ~= "" and meta:get_string("silver") ~= "" and meta:get_string("gold") ~= "" then return end

		return default.can_interact_with_node(player, pos)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)

		local player_meta = clicker:get_meta()
		local coins = minetest.deserialize(player_meta:get_string("player_coins"))
		local playerlist = minetest.deserialize(meta:get_string("playerlist"))

		if not minetest.check_player_privs(clicker, { core_admin = true }) then
			if meta:get_string("bronze") == "" or meta:get_string("silver") == "" or meta:get_string("gold") == "" then
				meta:set_string("formspec", "")

				minetest.chat_send_player(clicker:get_player_name(), S("You don't have sufficient permission to open this chest. Missing privileges: core_admin"))
				return
			else
				-- Start: special thanks to neinwhal for building the code!
				if playerlist then
					for _, names in ipairs(playerlist) do
						if clicker:get_player_name() == names then
							minetest.chat_send_player(clicker:get_player_name(), S("You have already got the coins from this chest."))
							return
						end
					end
				end

				meta:set_string("formspec", "")
				if coins then
					if no_coins(meta) == true then
						minetest.chat_send_player(clicker:get_player_name(), S("No coins have been set. You won't receive any coins."))
						return
					else
						coins.bronze_coins = coins.bronze_coins + tonumber(meta:get_string("bronze"))
						coins.silver_coins = coins.silver_coins + tonumber(meta:get_string("silver"))
						coins.gold_coins = coins.gold_coins + tonumber(meta:get_string("gold"))
					end

					player_meta:set_string("player_coins", minetest.serialize(coins))
				else
					coins = {
						bronze_coins = tonumber(meta:get_string("bronze")) or 0,
						silver_coins = tonumber(meta:get_string("silver")) or 0,
						gold_coins = tonumber(meta:get_string("gold")) or 0
					}
					player_meta:set_string("player_coins", minetest.serialize(coins))
				end
				minetest.chat_send_player(clicker:get_player_name(), S("You got @1 bronze coin(s), @2 silver coin(s), and @3 gold coin(s)!", tonumber(meta:get_string("bronze")), tonumber(meta:get_string("silver")), tonumber(meta:get_string("gold"))))

				minetest.sound_play("default_chest_open", {gain = 0.3,
					pos = pos, max_hear_distance = 10}, true)

				minetest.after(3, function()
					minetest.sound_play("default_chest_close", { gain = 0.3,
						pos = pos, max_hear_distance = 10 }, true)
				end)

				-- If no name found, store new value
				if no_coins(meta) ~= true then
					playerlist[#playerlist + 1] = clicker:get_player_name()
					meta:set_string("playerlist", minetest.serialize(playerlist))
				end
				-- End: special thanks to neinwhal for building the code!
			end
		else
			meta:set_string("formspec", show_formspec(meta))
			minetest.sound_play("default_chest_open", { gain = 0.3,
				pos = pos, max_hear_distance = 10 }, true)
        end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local player_meta = puncher:get_meta()

		local coins = minetest.deserialize(player_meta:get_string("player_coins"))
		if meta and minetest.check_player_privs(puncher, { core_admin = true }) and meta:get_int("staff_coins") == 1 then
			meta:set_string("formspec", "")
				if coins then
					if no_coins(meta) == true then
						minetest.chat_send_player(puncher:get_player_name(), S("No coins have been set. You won't receive any coins."))
						return
					else
						coins.bronze_coins = coins.bronze_coins + tonumber(meta:get_string("bronze"))
						coins.silver_coins = coins.silver_coins + tonumber(meta:get_string("silver"))
						coins.gold_coins = coins.gold_coins + tonumber(meta:get_string("gold"))
					end

					player_meta:set_string("player_coins", minetest.serialize(coins))
				else
					coins = {
						bronze_coins = tonumber(meta:get_string("bronze")) or 0,
						silver_coins = tonumber(meta:get_string("silver")) or 0,
						gold_coins = tonumber(meta:get_string("gold")) or 0
					}
					player_meta:set_string("player_coins", minetest.serialize(coins))
				end
				minetest.chat_send_player(puncher:get_player_name(), S("You got @1 bronze coin(s), @2 silver coin(s), and @3 gold coin(s)!", tonumber(meta:get_string("bronze")), tonumber(meta:get_string("silver")), tonumber(meta:get_string("gold"))))
				minetest.sound_play("default_chest_open", {gain = 0.3,
					pos = pos, max_hear_distance = 10}, true)

				minetest.after(3, function()
					minetest.sound_play("default_chest_close", { gain = 0.3,
						pos = pos, max_hear_distance = 10 }, true)
				end)
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", show_formspec(meta))
		meta:set_string("playerlist", minetest.serialize({}))
		meta:set_string("owner", "")
		meta:set_string("infotext", minetest.get_translator("default")("Chest"));
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		if fields.apply then
			if fields.bronze == "0" or
				fields.silver == "0" or fields.gold == "0" then
				minetest.chat_send_player(sender:get_player_name(), S("Please specify a valid value different than zero."))
				return
			end

			meta:set_string("bronze", fields.bronze)
			meta:set_string("silver", fields.silver)
			meta:set_string("gold", fields.gold)

			minetest.chat_send_player(sender:get_player_name(), S("Successfully updated/set coin chest!"))
			meta:set_string("formspec", show_formspec(meta))
		end
		if fields.staff_coins then
			meta:set_int("staff_coins", (fields.staff_coins == "true") and 1 or 0) -- Special thanks to LandarVangan/LoneWolfHT for helping!
		end
		if fields.quit then
			minetest.sound_play("default_chest_close", {gain = 0.3,
					pos = pos, max_hear_distance = 10}, true)
		end
	end,
	on_blast = function(pos)
		local meta = minetest.get_meta(pos)

		if meta:get_string("bronze") == "" and meta:get_string("silver") == "" and meta:get_string("gold") == "" then
			local drops = {}
			default.get_inventory_drops(pos, "main", drops)
			drops[#drops+1] = "pk_chest:chest"
			minetest.remove_node(pos)
			return drops
		else
			return
		end
	end
})

-- Backward compatibility aliases
minetest.register_alias("coin_chest:chest", "pk_chest:chest")
