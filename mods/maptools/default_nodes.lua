--[[
Map Tools: unbreakable default nodes

Copyright © 2012-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = maptools.S

maptools.creative = maptools.config["hide_from_creative_inventory"]

local function register_node(name, def)
	-- Increase the interaction range when holding Map Tools nodes to make building easier.
	def.range = 12
	def.stack_max = 10000
	def.drop = ""
	if def.groups then
		def.groups.unbreakable = 1
		def.groups.not_in_creative_inventory = maptools.creative
	else
		def.groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative}
	end
	def.on_drop = maptools.drop_msg
	-- Prevent Map Tools nodes from being exploded by TNT.
	def.on_blast = function() end
	minetest.register_node(name, def)
end

register_node("maptools:stone", {
	description = S("Unbreakable Stone"),
	tiles = {"default_stone.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:stonebrick", {
	description = S("Unbreakable Stone Brick"),
	tiles = {"default_stone_brick.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:tree", {
	description = S("Unbreakable Tree"),
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

register_node("maptools:jungletree", {
	description = S("Unbreakable Jungle Tree"),
	tiles = {
		"default_jungletree_top.png",
		"default_jungletree_top.png",
		"default_jungletree.png",
	},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

register_node("maptools:cactus", {
	description = S("Unbreakable Cactus"),
	tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_side.png"},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

register_node("maptools:papyrus", {
	description = S("Unbreakable Papyrus"),
	drawtype = "plantlike",
	tiles = {"default_papyrus.png"},
	inventory_image = "default_papyrus.png",
	wield_image = "default_papyrus.png",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
	},
	sounds = default.node_sound_leaves_defaults()
})

register_node("maptools:dirt", {
	description = S("Unbreakable Dirt"),
	tiles = {"default_dirt.png"},
	sounds = default.node_sound_dirt_defaults()
})

register_node("maptools:wood", {
	description = S("Unbreakable Wooden Planks"),
	tiles = {"default_wood.png"},
	sounds = default.node_sound_wood_defaults()
})

register_node("maptools:junglewood", {
	description = S("Unbreakable Junglewood Planks"),
	tiles = {"default_junglewood.png"},
	sounds = default.node_sound_wood_defaults()
})

register_node("maptools:glass", {
	description = S("Unbreakable Glass"),
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults()
})

register_node("maptools:leaves", {
	description = S("Unbreakable Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"default_leaves.png"},
	paramtype = "light",
	sounds = default.node_sound_leaves_defaults()
})

register_node("maptools:sand", {
	description = S("Unbreakable Sand"),
	tiles = {"default_sand.png"},
	sounds = default.node_sound_sand_defaults()
})

register_node("maptools:gravel", {
	description = S("Unbreakable Gravel"),
	tiles = {"default_gravel.png"},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.35},
		dug = {name="default_gravel_footstep", gain=0.6},
	})
})

register_node("maptools:clay", {
	description = S("Unbreakable Clay"),
	tiles = {"default_clay.png"},
	sounds = default.node_sound_dirt_defaults()
})

register_node("maptools:desert_sand", {
	description = S("Unbreakable Desert Sand"),
	tiles = {"default_desert_sand.png"},
	sounds = default.node_sound_sand_defaults()
})

register_node("maptools:sandstone", {
	description = S("Unbreakable Sandstone"),
	tiles = {"default_sandstone.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:sandstone_brick", {
	description = S("Unbreakable Sandstone Brick"),
	tiles = {"default_sandstone_brick.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:desert_stone", {
	description = S("Unbreakable Desert Stone"),
	tiles = {"default_desert_stone.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:desert_cobble", {
	description = S("Unbreakable Desert Cobble"),
	tiles = {"default_desert_cobble.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:desert_stonebrick", {
	description = S("Unbreakable Desert Stone Brick"),
	tiles = {"default_desert_stone_brick.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:grass", {
	description = S("Unbreakable Dirt with Grass"),
	tiles = {
		"default_grass.png",
		"default_dirt.png",
		"default_dirt.png^default_grass_side.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain = 0.4},
	})
})

register_node("maptools:fullgrass", {
	description = S("Unbreakable Full Grass"),
	tiles = {"default_grass.png"},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	})
})

for slab_num = 1,3,1 do
	register_node("maptools:slab_grass_" .. slab_num * 4, {
		description = S("Grass Slab"),
		tiles = {
			"default_grass.png",
			"default_dirt.png",
			"default_dirt.png^maptools_grass_side_" .. slab_num * 4 .. ".png",
		},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + slab_num * 0.25, 0.5},
		},
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		sounds = default.node_sound_dirt_defaults(
			{footstep = {name="default_grass_footstep", gain = 0.4}}
		)
	})
end

register_node("maptools:cobble", {
	description = S("Unbreakable Cobblestone"),
	tiles = {"default_cobble.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:mossycobble", {
	description = S("Unbreakable Mossy Cobblestone"),
	tiles = {"default_mossycobble.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:brick", {
	description = S("Unbreakable Brick"),
	tiles = {"default_brick.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:coalblock", {
	description = S("Unbreakable Coal Block"),
	tiles = {"default_coal_block.png"},
	sounds = default.node_sound_stone_defaults()
})


register_node("maptools:steelblock", {
	description = S("Unbreakable Steel Block"),
	tiles = {"default_steel_block.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:goldblock", {
	description = S("Unbreakable Gold Block"),
	tiles = {"default_gold_block.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:copperblock", {
	description = S("Unbreakable Copper Block"),
	tiles = {"default_copper_block.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:bronzeblock", {
	description = S("Unbreakable Bronze Block"),
	tiles = {"default_bronze_block.png"},
	sounds = default.node_sound_stone_defaults()
})

register_node("maptools:diamondblock", {
	description = S("Unbreakable Diamond Block"),
	tiles = {"default_diamond_block.png"},
	sounds = default.node_sound_stone_defaults()
})

-- Farming:

register_node("maptools:soil_wet", {
	description = "Wet Soil",
	tiles = {
		"default_dirt.png^farming_soil_wet.png",
		"default_dirt.png^farming_soil_wet_side.png",
	},
	groups = {
		soil = 3,
		wet = 1,
		grassland = 1,
	},
	sounds = default.node_sound_dirt_defaults()
})

register_node("maptools:desert_sand_soil_wet", {
	description = "Wet Desert Sand Soil",
	tiles = {"farming_desert_sand_soil_wet.png", "farming_desert_sand_soil_wet_side.png"},
	groups = {
		soil = 3,
		wet = 1,
		desert = 1,
	},
	sounds = default.node_sound_sand_defaults()
})
