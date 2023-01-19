pk_info = {
    S = minetest.get_translator(minetest.get_current_modname()),
}

local time_init = minetest.get_us_time()
local modpath = minetest.get_modpath("pk_info")

-- Rules --
dofile(modpath .. "/src/rules.lua")

-- About --
dofile(modpath .. "/src/about.lua")

local done = (minetest.get_us_time() - time_init) / 1000000
minetest.log("info", "[PK Information Mod] loaded [" .. done .. "s]")
