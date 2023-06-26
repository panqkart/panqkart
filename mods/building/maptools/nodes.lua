--[[
Map Tools: node definitions

Copyright © 2012-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = maptools.S
local register_node = maptools.register_node

maptools.creative = maptools.config["hide_from_creative_inventory"]

-- Redefine cloud so that the admin pickaxe can mine it
register_node(":default:cloud", {
	description = S("Cloud"),
	tiles = {"default_cloud.png"},
	sounds = default.node_sound_defaults(),
})

-- Nodes

register_node("maptools:black", {
	description = S("Black"),
	tiles = {"black.png"},
	post_effect_color = {a=255, r=0, g=0, b=0},
	sounds = default.node_sound_stone_defaults(),
})

register_node("maptools:white", {
	description = S("White"),
	tiles = {"white.png"},
	post_effect_color = {a=255, r=128, g=128, b=128},
	sounds = default.node_sound_stone_defaults(),
})

register_node("maptools:playerclip", {
	description = S("Player Clip"),
	inventory_image = "default_steel_block.png^dye_green.png",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	sunlight_propagates = true,
})

register_node("maptools:fake_walkable", {
	description = S("Player Clip"),
	inventory_image = "default_steel_block.png^dye_green.png",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0},
		},
	},
})

register_node("maptools:fullclip", {
	description = S("Full Clip"),
	inventory_image = "default_steel_block.png^dye_blue.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
})

register_node("maptools:fake_walkable_pointable", {
	description = S("Player Clip"),
	inventory_image = "default_steel_block.png^dye_green.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0},
		},
	},
})

register_node("maptools:ignore_like", {
	description = S("Ignore-like"),
	inventory_image = "default_steel_block.png^dye_pink.png",
	tiles = {"invisible.png"},
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
})

register_node("maptools:ignore_like_no_clip", {
	description = S("Ignore-like (no clip)"),
	inventory_image = "default_steel_block.png^dye_violet.png",
	tiles = {"invisible.png"},
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	use_texture_alpha = "clip",
})


register_node("maptools:ignore_like_no_point", {
	description = S("Ignore-like (no point)"),
	inventory_image = "default_steel_block.png^dye_violet.png",
	tiles = {"invisible.png"},
	paramtype = "light",
	pointable = false,
	sunlight_propagates = true,
	use_texture_alpha = "clip",
})

register_node("maptools:ignore_like_no_clip_no_point", {
	description = S("Ignore-like (no clip, no point)"),
	inventory_image = "default_steel_block.png^dye_pink.png",
	tiles = {"invisible.png"},
	paramtype = "light",
	walkable = false,
	pointable = false,
	sunlight_propagates = true,
})

register_node("maptools:fullclip_face", {
	description = S("Full Clip Face"),
	inventory_image = "default_steel_block.png^dye_white.png",
	drawtype = "nodebox",
	tiles = {"invisible.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
	},
	groups = {
		fall_damage_add_percent = -100,
	},
})

register_node("maptools:playerclip_bottom", {
	description = S("Player Clip Bottom Face"),
	inventory_image = "default_steel_block.png^dye_orange.png",
	drawtype = "nodebox",
	tiles = {"invisible.png"},
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
	},
	groups = {
		fall_damage_add_percent = -100,
	},
})

register_node("maptools:playerclip_top", {
	description = S("Player Clip Top Face"),
	inventory_image = "default_steel_block.png^dye_yellow.png",
	drawtype = "nodebox",
	tiles = {"invisible.png"},
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {-0.5, 0.4999, -0.5, 0.5, 0.5, 0.5},
	},
	groups = {
		fall_damage_add_percent = -100,
	},
})

for pusher_num=1,10,1 do
	register_node("maptools:pusher_" .. pusher_num, {
		description = S("Pusher (%s)"):format(pusher_num),
				inventory_image = "default_steel_block.png^default_apple.png",
		drawtype = "nodebox",
		tiles = {"invisible.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		use_texture_alpha = "clip",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
		},
		groups = {
			fall_damage_add_percent = -100,
			bouncy = pusher_num * 100,
		},
	})
end

register_node("maptools:lightbulb", {
	description = S("Light Bulb"),
	inventory_image = "default_steel_block.png^default_mese_crystal_fragment.png",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	light_source = 14,
	paramtype = "light",
	sunlight_propagates = true,
})

register_node("maptools:nobuild", {
	description = S("Build Prevention"),
	inventory_image = "default_steel_block.png^default_flint.png",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
})

register_node("maptools:nointeract", {
	description = S("Interact Prevention"),
	inventory_image = "default_steel_block.png^default_bush_stem.png",
	drawtype = "airlike",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
})

register_node("maptools:climb", {
	description = S("Climb Block"),
	inventory_image = "default_steel_block.png^default_ladder_wood.png",
	drawtype = "airlike",
	walkable = false,
	climbable = true,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
})

for damage_num=1,5,1 do
register_node("maptools:damage_" .. damage_num, {
	description = S("Damaging Block (%s)"):format(damage_num),
	inventory_image = "default_steel_block.png^farming_cotton_" .. damage_num .. ".png",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	damage_per_second = damage_num,
	paramtype = "light",
	sunlight_propagates = true,
})
end

register_node("maptools:kill", {
	description = S("Kill Block"),
	inventory_image = "default_steel_block.png^dye_black.png",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	damage_per_second = 20,
	paramtype = "light",
	sunlight_propagates = true,
})

register_node("maptools:smoke", {
	description = S("Smoke Block"),
	tiles = {"maptools_smoke.png"},
	drawtype = "allfaces_optional",
	walkable = false,
	paramtype = "light",
	post_effect_color = {a=192, r=96, g=96, b=96},
})

register_node("maptools:ladder", {
	description = S("Fake Ladder"),
	drawtype = "signlike",
	tiles = {"default_ladder_wood.png"},
	inventory_image = "default_ladder_wood.png",
	wield_image = "default_ladder_wood.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "wallmounted",
	},
	sounds = default.node_sound_wood_defaults(),
})

register_node("maptools:permanent_fire", {
	description = S("Permanent Fire"),
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {{
		name="fire_basic_flame_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "fire_basic_flame.png",
	light_source = 14,
	sunlight_propagates = true,
	walkable = false,
	damage_per_second = 4,
})

register_node("maptools:fake_fire", {
	description = S("Fake Fire"),
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {{
		name="fire_basic_flame_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "fire_basic_flame.png",
	light_source = 14,
	sunlight_propagates = true,
	walkable = false,
})

register_node("maptools:igniter", {
	drawtype = "airlike",
	description = S("Igniter"),
	paramtype = "light",
	inventory_image = "fire_basic_flame.png",
	groups = {igniter=2},
	sunlight_propagates = true,
	pointable = false,
	walkable = false,
})

register_node("maptools:superapple", {
	description = S("Super Apple"),
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"maptools_superapple.png"},
	inventory_image = "maptools_superapple.png",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	walkable = false,
	groups = {fleshy=3, dig_immediate=3, not_in_creative_inventory = maptools.creative},
	on_use = minetest.item_eat(20),
	sounds = default.node_sound_defaults(),
})

register_node("maptools:drowning", {
	description = S("Drownable Air"),
	inventory_image = "default_steel_block.png^dye_black.png",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	drowning = 1,
	sunlight_propagates = true,
})
