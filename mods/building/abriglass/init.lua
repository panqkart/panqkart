local modpath = minetest.get_modpath("abriglass").. DIR_DELIM

abriglass = {}

dofile(modpath.."nodes.lua")
dofile(modpath.."crafting.lua")
dofile(modpath.."compatibility.lua")

abriglass.init = true
