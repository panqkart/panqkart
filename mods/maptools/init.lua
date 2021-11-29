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

dofile(modpath .. "/config.lua")
dofile(modpath .. "/aliases.lua")
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/default_nodes.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/tools.lua")
