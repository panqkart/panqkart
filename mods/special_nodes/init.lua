--------------
-- Nodes --
--------------

local S = minetest.get_translator("default") -- This is used as the nodes have the same name as the default ones
local S2 = minetest.get_translator("core_game")

minetest.register_node("special_nodes:junglewood", {
	description = S("Jungle Wood Planks"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
})

minetest.register_node("special_nodes:start_race", {
	description = S2("Start a race!"),
	tiles = {"default_mossycobble.png"},
	drop = "",
	light_source = 7,
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	on_place = function(itemstack, placer, pointed_thing)
		if not minetest.check_player_privs(placer, { core_admin = true }) then
			minetest.chat_send_player(placer:get_player_name(), S2("You don't have sufficient permissions to place this node. Missing privileges: core_admin"))
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
})

minetest.register_alias("core_game:junglenoob", "special_nodes:junglewood") -- Backwards compatibility (this used to be the old node name lol)
