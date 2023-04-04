vehicle_mash = { }

-- Fix `player_api` eye height model if desired
if minetest.settings:get_bool("player_api_fix") == true or minetest.settings:get_bool("player_api_fix") == nil
	and player_api.registered_models["character.b3d"] then

	player_api.registered_models["character.b3d"].animations.sit.eye_height = 1.47
end

-- get modpath

local mpath = minetest.get_modpath("vehicle_mash")
local craft_check = minetest.settings:get_bool("vehicles_crafts")

-- Do not change value at settingtypes.txt
-- Only change value at minetest.conf and Minetest Settings tab
local api_check = minetest.settings:get_bool("vehicle_mash.api_mode")

-- Set to default (false) if nil, because all options are normally
-- nil. This will also help with the boolean checks below.
if api_check == nil then
	minetest.settings:set_bool("vehicle_mash.api_mode", false)
end

if api_check then -- Now we can safely check if this option is enabled
	-- load framework
	dofile(mpath .. "/framework.lua")

	-- load crafts
	if craft_check or craft_check == nil then
		dofile(mpath .. "/crafts.lua")
	end
else
	-- load framework
	dofile(mpath .. "/framework.lua")

	-- load crafts
	if craft_check or craft_check == nil then
		dofile(mpath .. "/crafts.lua")
	end

	-- ***********************
	-- load vehicles down here
	-- ***********************

	-- ** CAR01s **
	------------------------------------------------------------------------------
	-- create CAR01 common def
	vehicle_mash.car01_def = {
		-- adjust to change how vehicle reacts while driving
		terrain_type = 1,
		max_speed_forward = 10,
		max_speed_reverse = 7,
		accel = 3,
		braking = 3,
		turn_speed = 2.75,
		stepheight = 1.1,
		-- model specific stuff
		visual = "mesh",
		mesh = "car.x",
		visual_size = {x=1, y=1},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.6, -0.05, -0.6, 0.6, 1, 0.6},
		onplace_position_adj = -0.45,
		-- player specific stuff
		player_rotation = vector.new(0,90,0),
		driver_attach_at = vector.new(3.5,3.7,3.5),
		driver_eye_offset = vector.new(-4,0,0),
		number_of_passengers = 0,

		passengers = {
			{
				attach_at = vector.new(3.5,3.7,-3.5),
				eye_offset = vector.new(4,0,0),
			},
			{
				attach_at = vector.new(-4,3.7,3.5),
				eye_offset = vector.new(-4,3,0),
			},
			{
				attach_at = vector.new(-4,3.7,-3.5),
				eye_offset = vector.new(4,3,0),
			},
		},

		enable_crash = false,

		-- drop and recipe
		drop_on_destroy = {"vehicle_mash:tire 2", "vehicle_mash:windshield",
			"vehicle_mash:battery", "vehicle_mash:motor"},
		recipe = nil
	}

	local car01_names = {
		"black", "blue", "brown", "cyan",
		"dark_green", "dark_grey", "green",
		"grey", "magenta", "orange",
		"pink", "red", "violet",
		"white", "yellow", "hot_rod",
		"nyan_ride", "oerkki_bliss", "road_master",
	}

	-- Load all CAR01's cars if enabled
	for _, name in ipairs(car01_names) do
		local check_enabled = minetest.settings:get_bool("vehicle_mash.enable_" .. name .. "_car")
		if check_enabled or check_enabled == nil then
			loadfile(mpath .. "/car01s/" .. name .. ".lua")(table.copy(vehicle_mash.car01_def))
		end
	end

	-- ** Hovercraft **
	------------------------------------------------------------------------------
	-- create hovercraft common def
	vehicle_mash.hover_def = {
		-- adjust to change how vehicle reacts while driving
		terrain_type = 1,
		max_speed_forward = 10.50,
		max_speed_reverse = 4.5,
		accel = 2,
		braking = 2,
		turn_speed = 2,
		stepheight = 1.1,
		-- model specific stuff
		visual = "mesh",
		mesh = "hovercraft.x",
		visual_size = {x=1, y=1},
		wield_scale = {x=1, y=1, z=1},
		collisionbox = {-0.8, -0.25, -0.8, 0.8, 1.2, 0.8}, -- TODO: fix collisionbox
		onplace_position_adj = -0.25,
		-- player specific stuff
		player_rotation = vector.new(0,90,0),
		driver_attach_at = vector.new(-2,6.3,0),
		driver_eye_offset = vector.new(0,0,0),
		number_of_passengers = 0,

		passengers = {
			{
				attach_at = vector.new(0,0,0),
				eye_offset = vector.new(0,0,0),
			},
		},

		enable_crash = false,

		-- recipe
		recipe = nil
	}

	local hover_names = {
		"hover_blue",
		"hover_green",
		"hover_red",
		"hover_yellow",
	}

	-- Load hovercrafts if enabled
	for _, name in ipairs(hover_names) do
		local check_enabled = minetest.settings:get_bool("vehicle_mash.enable_" .. name)
		if check_enabled or check_enabled == nil then
			loadfile(mpath .. "/hovers/" .. name .. ".lua")(table.copy(vehicle_mash.hover_def))
		end
	end
end

-- free unneeded global(s)
core.after(10, function()
	vehicle_mash.register_vehicle = nil
end)

-- Unused functions/code. Might be used in the future.
--[[
	-- ** MeseCars **
	------------------------------------------------------------------------------
	-- create Mesecar common def
	local mesecar_def = {
		-- adjust to change how vehicle reacts while driving
		terrain_type = 1,
		max_speed_forward = 10,
		max_speed_reverse = 7,
		accel = 3,
		braking = 6,
		turn_speed = 4,
		stepheight = 0.6,
		-- model specific stuff
		visual = "cube",
		mesh = "",
		visual_size = {x=1.5, y=1.5},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.75, -0.75, -0.75, 0.75, 0.75, 0.75},
		onplace_position_adj = 0.25,
		-- player specific stuff
		player_rotation = vector.new(0,0,0),
		driver_attach_at = vector.new(0,0,-2.0),
		driver_eye_offset = vector.new(0,0,0),
		number_of_passengers = 0,

		passengers = {
			{
				attach_at = vector.new(0,0,0),
				eye_offset = vector.new(0,0,0),
			},
		},

		-- HP/Armor stuff. Uncomment to enable.
		-- min_hp = 10,
		-- max_hp = 35,
		-- armor = 25,

		-- drop and recipe
		drop_on_destroy = {"vehicle_mash:motor", "vehicle_mash:battery"},
		recipe = nil
	}

	local mesecar_names = {
		"mese_blue",
		"mese_pink",
		"mese_purple",
		"mese_yellow",
	}

	-- Load all Mese Cars if enabled
	for _, name in ipairs(mesecar_names) do
		local check_enabled = minetest.settings:get_bool("vehicle_mash.enable_" .. name .. "_car")
		if check_enabled or check_enabled == nil then
			loadfile(mpath .. "/mesecars/" .. name .. ".lua")(table.copy(mesecar_def))
		end
	end

	-- ** Boats **
	------------------------------------------------------------------------------
	-- create boats common def
	local boat_def = {
		-- adjust to change how vehicle reacts while driving
		terrain_type = 2,
		max_speed_forward = 3,
		max_speed_reverse = 3,
		accel = 3,
		braking = 3,
		turn_speed = 3,
		stepheight = 0,
		-- model specific stuff
		visual = "mesh",
		visual_size = {x=1, y=1},
		wield_scale = vector.new(1,1,1),
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		onplace_position_adj = 0,
		textures = {"default_wood.png"},
		-- player specific stuff
		player_rotation = vector.new(0,0,0),
		driver_attach_at = vector.new(0.5,1,-3),
		driver_eye_offset = vector.new(0,0,0),
		number_of_passengers = 0,
		passengers = {
			{
				attach_at = vector.new(0,0,0),
				eye_offset = vector.new(0,0,0),
			},
		},

		-- HP/Armor stuff. Uncomment to enable.
		-- min_hp = 10,
		-- max_hp = 35,
		-- armor = 25,
	}

	local boat_names = {
		"boat",
		"rowboat",
	}

	-- Load boats if enabled
	for _, name in ipairs(boat_names) do
		local check_enabled = minetest.settings:get_bool("vehicle_mash.enable_" .. name)
		if check_enabled or check_enabled == nil then
			loadfile(mpath .. "/boats/" .. name .. ".lua")(table.copy(boat_def))
		end
	end
--]]
