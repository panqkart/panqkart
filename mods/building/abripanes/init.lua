local modpath = minetest.get_modpath("abripanes").. DIR_DELIM

abripanes = {}

dofile(modpath.."api.lua")
dofile(modpath.."nodes.lua")

abripanes.init = true
