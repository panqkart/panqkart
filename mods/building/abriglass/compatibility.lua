-- the code is written on the assumption that
-- https://forum.minetest.net/viewtopic.php?p=396571&sid=17cb7c20fb158e9b994ea08fee4509cf#p396571 is true

---------------------
--for stained glass--
---------------------

local stainedoldnodes = {
    "abriglass:stained_glass_black", "abriglass:stained_glass_blue",
    "abriglass:stained_glass_cyan", "abriglass:stained_glass_green",
    "abriglass:stained_glass_magenta", "abriglass:stained_glass_orange",
    "abriglass:stained_glass_purple", "abriglass:stained_glass_red",
    "abriglass:stained_glass_yellow", "abriglass:stained_glass_frosted",
}

local stainedoldnodes_to_new = {
    ["abriglass:stained_glass_black"] = 0,
    ["abriglass:stained_glass_blue"] = 1,
    ["abriglass:stained_glass_cyan"] = 2,
    ["abriglass:stained_glass_green"] = 3,
    ["abriglass:stained_glass_magenta"] = 4,
    ["abriglass:stained_glass_orange"] = 5,
    ["abriglass:stained_glass_purple"] = 6,
    ["abriglass:stained_glass_red"] = 7,
    ["abriglass:stained_glass_yellow"] = 8,
    ["abriglass:stained_glass_frosted"] = 9,
}

--convert old glass to hardware colored
minetest.register_lbm({
	label="abriglass: convert old glass",
	name="abriglass:glass_convert",
	nodenames=stainedoldnodes,
	run_at_every_load = false,
	action = function(pos, node)
		minetest.set_node(pos, {name="abriglass:stained_glass_hardware", param2 = stainedoldnodes_to_new[node.name]})
	end,
})

for _, nodename in pairs(stainedoldnodes) do
    local splitname = nodename:split("_")
    local colorinfo = abriglass.glass_list[stainedoldnodes_to_new[nodename] + 1]
    local textureside = "abriglass_baseglass.png^[colorize:#" .. colorinfo[3] .. ":255"

    minetest.register_craftitem(nodename, {
        description = splitname[#splitname] .. " glass",
        wield_image = "[combine:1x1", -- no way to fake this, so nothing for now
        inventory_image = minetest.inventorycube(textureside),
        groups = {not_in_creative_inventory = 1},
        on_place = function(itemstack, placer, pointed_thing)
            local newstack = ItemStack(minetest.itemstring_with_palette(
                "abriglass:stained_glass_hardware",
                stainedoldnodes_to_new[nodename]
            ))

            newstack:set_count(itemstack:get_count())
            newstack:get_meta():set_string("description", splitname[#splitname] .. " glass")

            --have the benifit that the return stack will be in the node format
            return minetest.item_place(newstack, placer, pointed_thing)
        end,
    })
end

-------------------
--for light glass--
-------------------

local lightoldnodes = {
    "abriglass:glass_light_green", "abriglass:glass_light_blue",
    "abriglass:glass_light_yellow", "abriglass:glass_light_red"
}

local lightstainedoldnodes_to_new = {
    ["abriglass:glass_light_green"] = 3,
    ["abriglass:glass_light_blue"] = 1,
    ["abriglass:glass_light_yellow"] = 8,
    ["abriglass:glass_light_red"] = 7,
}

--convert old glass to hardware colored
minetest.register_lbm({
	label="abriglass: convert old light glass",
	name="abriglass:lightglass_convert",
	nodenames=lightoldnodes,
	run_at_every_load = false,
	action = function(pos, node)
		minetest.set_node(pos, {name="abriglass:glass_light_hardware", param2 = lightstainedoldnodes_to_new[node.name]})
	end,
})

for _, nodename in pairs(lightoldnodes) do
    local splitname = nodename:split("_")
    local colorinfo = abriglass.glass_list[lightstainedoldnodes_to_new[nodename] + 1]
    local textureside = "abriglass_baseglass.png^[colorize:#" .. colorinfo[3] .. ":255^abriglass_clearglass.png"

    minetest.register_craftitem(nodename, {
        description = splitname[#splitname] .. " glass light",
        wield_image = "[combine:1x1", -- no way to fake this, so nothing for now
        inventory_image = minetest.inventorycube(textureside),
        groups = {not_in_creative_inventory = 1},
        on_place = function(itemstack, placer, pointed_thing)
            local newstack = ItemStack(minetest.itemstring_with_palette(
                "abriglass:glass_light_hardware",
                lightstainedoldnodes_to_new[nodename]
            ))

            newstack:set_count(itemstack:get_count())
            newstack:get_meta():set_string("description", splitname[#splitname] .. " glass light")

            --have the benifit that the return stack will be in the node format
            return minetest.item_place(newstack, placer, pointed_thing)
        end,
    })
end