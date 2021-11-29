--[[
	## StreetsMod 2.0 ##
	Submod: streetsmod
	Optional: false
	Category: Init
]]

print("[Mod][StreetsMod] Loading...")
-- Register a global streets namespace to operate in
streets = {}

-- Config stuff goes here
streets.conf = {
	version = "2.0",
	licenseCode = "MIT License",
	licenseMedia = "CC-BY-SA 3.0",
	modpath = minetest.get_modpath("streets")
}

-- The API collects some data here
streets.surfaces = { surfacetypes = {} }
streets.labels = { labeltypes = {} }
streets.signs = { signtypes = {} }

-- Load the API file
dofile(streets.conf.modpath .. "/api.lua")

-- Load global definitions
dofile(streets.conf.modpath .. "/global.lua")

-- Load mod files
streets.load_submod("streets_roadsurface")
streets.load_submod("streets_roadmarkings")
streets.load_submod("streets_installations")
streets.load_submod("streets_accessories")
streets.load_submod("streets_concrete")
streets.load_submod("streets_poles")
streets.load_submod("streets_rrxing")
streets.load_submod("streets_signs")
streets.load_submod("streets_steelsupport")
streets.load_submod("streets_roadwork")
streets.load_submod("streets_bollards")
streets.load_submod("streets_light")
streets.load_submod("streets_workshop")

if minetest.get_modpath("digilines") then
	streets.load_submod("streets_trafficlight")
	streets.load_submod("streets_laneuse")
	streets.load_submod("streets_matrix_screen")
end

-- Let the API register everything and finish the setup
dofile(streets.conf.modpath .. "/api_register_all.lua")
