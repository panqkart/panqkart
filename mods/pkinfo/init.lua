local init = minetest.get_us_time()
local lane = minetest.get_modpath('pkinfo')

-- Rules --
dofile(lane.."/src/rules.lua")

-- About --
dofile(lane.."/src/about.lua")

local done = (minetest.get_us_time() - init) / 1000000

print('[PK Information Mod] loaded.. [' .. done .. 's]')