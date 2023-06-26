--[[
=====================================================================
** Map Tools **
By Calinou.

Copyright © 2012-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
=====================================================================
--]]

maptools = {}

local modpath = minetest.get_modpath("maptools")

local S = minetest.get_translator("maptools")
maptools.S = S

maptools.drop_msg = function(itemstack, player)
	local name = player:get_player_name()
	minetest.chat_send_player(name, S("[maptools] tools/nodes do not drop!"))
end

function maptools.register_node(name, def)
	-- Increase the interaction range when holding Map Tools nodes to make building easier.
	def.range = 12
	def.stack_max = 65535
	def.drop = ""
	if def.groups then
		if not def.groups.dig_immediate then
			def.groups.unbreakable = 1
		end
		def.groups.not_in_creative_inventory = maptools.creative
	else
		def.groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative}
	end
	def.on_drop = maptools.drop_msg
	-- Prevent Map Tools nodes from being exploded by TNT.
	def.on_blast = function() end
	minetest.register_node(name, def)
end

dofile(modpath .. "/config.lua")
dofile(modpath .. "/aliases.lua")
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/default_nodes.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/tools.lua")
