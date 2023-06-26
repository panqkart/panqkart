--[[
Map Tools: configuration handling

Copyright © 2012-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

maptools.config = {}

local function getbool_default(setting, default)
	local value = minetest.settings:get_bool(setting)
	if value == nil then
		value = default
	end
	return value
end

local function setting(settingtype, name, default)
	if settingtype == "bool" then
		maptools.config[name] =
			getbool_default("maptools." .. name, default)
	else
		maptools.config[name] =
			minetest.settings:get("maptools." .. name) or default
	end
end

-- Show Map Tools stuff in creative inventory (1 or 0):
setting("integer", "hide_from_creative_inventory", 1)
-- Enable crafting recipes for coins (true or false):
setting("bool", "enable_coin_crafting", false)
