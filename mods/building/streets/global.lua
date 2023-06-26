--[[
	## StreetsMod 2.0 ##
	Submod: streetsmod
	Optional: false
	Category: Init
]]

streets.nodeboxes = {}

streets.nodeboxes.stair = {
	{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
	{ -0.5, 0, 0, 0.5, 0.5, 0.5 }
}
streets.nodeboxes.slab = {
	{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 }
}

if minetest.get_modpath("concrete") then
	streets.concrete_texture = "technic_concrete_block.png"
else
	streets.concrete_texture = "streets_concrete.png"
end

streets.only_basic_stairsplus = true
if minetest.settings:get_bool("streets.only_basic_stairsplus") == false then
	streets.only_basic_stairsplus = false
end