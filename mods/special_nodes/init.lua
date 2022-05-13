--------------
-- Nodes --
--------------

local S = minetest.get_translator("default") -- This is used as the nodes have the same name as the default ones

minetest.register_node("special_nodes:junglewood", {
	description = S("Jungle Wood Planks"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
})

minetest.register_alias("core_game:junglenoob", "special_nodes:junglewood") -- Backwards compatibility (this used to be the old node name lol)
