local storage = minetest.get_mod_storage()

----------------
-- Formspecs --
----------------
local function show_formspec(name)
	local text = "Choose the options here."
	local formspec = {
		"formspec_version[4]",
		"size[7,5]",
		"label[1.25,0.5;", minetest.formspec_escape(text), "]",
		"field[0.375,1.2;5.25,0.8;bronze;Bronze coins;0]",
		"field[0.375,2.13;5.25,0.8;silver;Silver coins;0]",
		"field[0.375,3;5.25,0.8;silver;Gold coins;0]",
		"button_exit[2,4;3,0.8;apply;Apply changes]"
	}

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "coin_chest:options" then
		return
	end

	if fields.bronze then
		local name = player:get_player_name()
		local context = get_context(name)
		context.guess = tonumber(fields.number)
		show_to(name)
	end
end)

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
	on_place = function(itemstack, placer, pointed_thing)
        if not minetest.check_player_privs(placer, { core_admin = true }) then
            return false, "You don't have the sufficient permissions to place this node. Missing privileges: core_admin"
        end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if not minetest.check_player_privs(placer, { core_admin = true }) then
            return false, "You don't have the sufficient permissions to place this node. Missing privileges: core_admin"
        end
		minetest.show_formspec(placer:get_player_name(), "coin_chest:options", show_formspec(placer))

		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest");
    end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.check_player_privs(clicker, { core_admin = true }) then
            return false, "You don't have the sufficient permissions to place this node. Missing privileges: core_admin"
        end
		minetest.show_formspec(clicker:get_player_name(), "coin_chest:options", show_formspec(clicker))
	end,
})


