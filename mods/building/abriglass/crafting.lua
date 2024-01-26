
-- clear glass recipe
minetest.register_craft({
	output = 'abriglass:clear_glass 4', -- intentional lower yield
	recipe = {
		{'default:glass', '', 'default:glass' },
		{'', 'default:glass', '' },
		{'default:glass', '', 'default:glass' },
	}
})

-- undecorated coloured glass recipes / light glass
local dye_list = {
	{"black", "black",},
	{"blue", "blue",},
	{"cyan", "cyan",},
	{"green", "green",},
	{"magenta", "magenta",},
	{"orange", "orange",},
	{"purple", "violet",},
	{"red", "red",},
	{"yellow", "yellow",},
	{"frosted", "white",},
}

local sg_conversion_table = {}

for k, v in pairs(dye_list) do
    local out_item = ItemStack(minetest.itemstring_with_palette("abriglass:stained_glass_hardware", k - 1))
    out_item:get_meta():set_string("description", v[1] .. " glass")
    minetest.register_craft({
        output = out_item:to_string(),
        recipe = {
			{'abriglass:clear_glass', '', 'abriglass:clear_glass' },
			{'abriglass:clear_glass', 'dye:'..v[2], 'abriglass:clear_glass' },
			{'abriglass:clear_glass', '', 'abriglass:clear_glass' },
		}
    })

	minetest.register_craft({
		type = "cooking",
		recipe = out_item:to_string(),
		output = "abriglass:clear_glass",
	})

	sg_conversion_table[v[1]] = out_item:to_string()

	out_item = ItemStack(minetest.itemstring_with_palette("abriglass:glass_light_hardware", k - 1))
    out_item:get_meta():set_string("description", v[1] .. " glass light")
	minetest.register_craft({
		output = out_item:to_string(),
		recipe = {
			{'abriglass:clear_glass', 'default:torch', 'abriglass:clear_glass' },
			{'abriglass:clear_glass', 'dye:'..v[2], 'abriglass:clear_glass' },
		}
	})

	minetest.register_craft({
		type = "cooking",
		recipe = out_item:to_string(),
		output = "abriglass:clear_glass",
	})
end


-- patterned glass recipes
minetest.register_craft({
	output = 'abriglass:stainedglass_pattern02 9',
	recipe = {
		{'abriglass:clear_glass', 'abriglass:clear_glass', 'abriglass:clear_glass' },
		{'abriglass:clear_glass', 'abriglass:clear_glass', 'abriglass:clear_glass' },
		{'abriglass:clear_glass', 'abriglass:clear_glass', 'abriglass:clear_glass' },
	}
})

--tldr: minetest with hardware coloring sucks | this is one massive hack to work around it

--the last item of each set is what minetest will trigger on for these
local hardware_colored_crafts_1 = {
	--start first set
	{
		item = 'abriglass:stainedglass_tiles_dark 7',
		craft = {
			{sg_conversion_table['red'], sg_conversion_table['green'], sg_conversion_table['blue'] },
			{sg_conversion_table['yellow'], sg_conversion_table['magenta'], sg_conversion_table['cyan'] },
			{'', sg_conversion_table['black'], '' },
		}
	},
	{
		item = 'abriglass:stainedglass_tiles_pale 7',
		craft = {
			{sg_conversion_table['red'], sg_conversion_table['green'], sg_conversion_table['blue'] },
			{sg_conversion_table['yellow'], sg_conversion_table['magenta'], sg_conversion_table['cyan'] },
			{'', sg_conversion_table['frosted'], '' },
		}
	},
	--end first set
	--start second ser
	{
		item = "abriglass:stainedglass_pattern01 9",
		craft = {
			{sg_conversion_table['yellow'], sg_conversion_table['yellow'], sg_conversion_table['yellow'] },
			{sg_conversion_table['yellow'], sg_conversion_table['yellow'], sg_conversion_table['yellow'] },
			{sg_conversion_table['yellow'], sg_conversion_table['yellow'], sg_conversion_table['yellow'] },
		}
	},
	{
		item = "abriglass:stainedglass_pattern03 9",
		craft = {
			{sg_conversion_table['red'], 'abriglass:clear_glass', sg_conversion_table['red'] },
			{'abriglass:clear_glass', 'abriglass:clear_glass', 'abriglass:clear_glass' },
			{sg_conversion_table['red'], 'abriglass:clear_glass', sg_conversion_table['red'] },
		}
	},
	{
		item = "abriglass:stainedglass_pattern04 9",
		craft = {
			{sg_conversion_table['green'], sg_conversion_table['red'], sg_conversion_table['green'] },
			{sg_conversion_table['red'], sg_conversion_table['blue'], sg_conversion_table['red'] },
			{sg_conversion_table['green'], sg_conversion_table['red'], sg_conversion_table['green'] },
		}
	},
	{
		item = "abriglass:stainedglass_pattern05 9",
		craft = {
			{sg_conversion_table['blue'], sg_conversion_table['blue'], sg_conversion_table['blue'] },
			{sg_conversion_table['blue'], sg_conversion_table['green'], sg_conversion_table['blue'] },
			{sg_conversion_table['blue'], sg_conversion_table['blue'], sg_conversion_table['blue'] },
		}
	}
	--end second set
}

local hcc_encoded_1 = {}

--encode things we care about, in order, since itemstack:to_string is worthless for comparisions
local function craft_encode(input)
	local output = ""
	for _, v in ipairs(input) do --care about order
		local row = ""
		for _, j in ipairs(v) do --care about order
			local item = ItemStack(j)
			row = row..item:get_name()..(item:get_meta():get("description") or "")..(item:get_meta():get("palette_index") or "")
		end
		output = output .. "," .. row
	end
	return output
end

--we actually care about order
for _,v in ipairs(hardware_colored_crafts_1) do
	minetest.register_craft({
		output = v.item,
		recipe = v.craft
	})

	hcc_encoded_1[craft_encode(v.craft)] = v.item
end

local function hcc_1_func(itemstack, player, old_craft_grid, craft_inv)
	--return things we dont care about | check for the last item of each set since everything does stuff in order
	if itemstack:get_name()~="abriglass:stainedglass_pattern05"
		and itemstack:get_name()~="abriglass:stainedglass_tiles_pale" then return end

	local encoded = craft_encode({
		{old_craft_grid[1], old_craft_grid[2], old_craft_grid[3]},
		{old_craft_grid[4], old_craft_grid[5], old_craft_grid[6]},
		{old_craft_grid[7], old_craft_grid[8], old_craft_grid[9]},
	})
	if (hcc_encoded_1[encoded]) then
		return ItemStack(hcc_encoded_1[encoded])
	else
		return ItemStack("")
	end
end

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	return hcc_1_func(itemstack, player, old_craft_grid, craft_inv)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	return hcc_1_func(itemstack, player, old_craft_grid, craft_inv)
end)


-- cooking recipes
local cook_list = {
	"stainedglass_pattern01",
	"stainedglass_pattern02",
	"stainedglass_pattern03",
	"stainedglass_pattern04",
	"stainedglass_pattern05",
	"stainedglass_tiles_dark",
	"stainedglass_tiles_pale"
}

for i = 1, #cook_list do
	local name = cook_list[i]

	minetest.register_craft({
		type = "cooking",
		recipe = "abriglass:"..name,
		output = "abriglass:clear_glass",
	})
end


-- porthole recipes
local port_recipes = {
	{"wood",}, {"junglewood",},
}

for i in ipairs(port_recipes) do
	local name = port_recipes[i][1]

	minetest.register_craft({
		output = "abriglass:porthole_"..name.." 4",
		recipe = {
			{"default:glass", "", "default:glass",},
			{"default:"..name, "", "default:steel_ingot",},
			{"default:glass", "", "default:glass",},
		}
	})
end


-- one-way recipes
local oneway_recipe_list = {
	{"abriglass:oneway_glass_desert_brick", "default:desert_stonebrick",},
	{"abriglass:oneway_glass_stone_brick", "default:stonebrick",},
	{"abriglass:oneway_glass_sandstone_brick", "default:sandstonebrick",},
	{"abriglass:oneway_glass_dark", "abriglass:oneway_wall_dark",},
	{"abriglass:oneway_glass_pale", "abriglass:oneway_wall_pale",},
}

for i in ipairs(oneway_recipe_list) do
	local name = oneway_recipe_list[i][1]
	local ingredient = oneway_recipe_list[i][2]

	minetest.register_craft({
		output = name.." 2",
		recipe = {
			{'abriglass:clear_glass', 'default:mese_crystal_fragment', ingredient },
		}
	})
end

minetest.register_craft({
	output = 'abriglass:oneway_wall_dark 2',
	recipe = {
		{'default:clay_lump', 'default:clay_lump', 'default:clay_lump'},
		{'default:clay_lump', 'dye:black', 'default:clay_lump'},
		{'default:clay_lump', 'default:clay_lump', 'default:clay_lump'},
	}
})

minetest.register_craft({
	output = 'abriglass:oneway_wall_pale 2',
	recipe = {
		{'default:clay_lump', 'default:clay_lump', 'default:clay_lump'},
		{'default:clay_lump', 'dye:white', 'default:clay_lump'},
		{'default:clay_lump', 'default:clay_lump', 'default:clay_lump'},
	}
})

minetest.register_craft({
	output = 'abriglass:ghost_crystal 4',
	recipe = {
		{'dye:cyan', 'abriglass:clear_glass', 'dye:cyan'},
		{'abriglass:clear_glass', 'default:meselamp', 'abriglass:clear_glass'},
		{'dye:cyan', 'abriglass:clear_glass', 'dye:cyan'},
	}
})

