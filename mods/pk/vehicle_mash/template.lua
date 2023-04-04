local name = "car_template"				-- mod name of vehicle

local definition = {
	terrain_type = 1,						-- 0 = air, 1 = land, 2 = liquid, 3 = land + liquid
	description = "Template car",			-- name as seen in inventory
	collisionbox = {0, 0, 0, 0, 0, 0},		-- back, bottom, starboard, front, top, port
	onplace_position_adj = 0,			-- adjust placement position up/down
	enable_crash = true,			-- whether to destroy the vehicle when going too fast and crashes with a block or not
	can_fly = false,					-- if enabled, the specified vehicle will be able to fly around
	can_go_down = false, 				-- applies only when `can_fly` is enabled
	can_go_up = false, 	 				-- applies only when `can_fly` is enabled
	player_rotation = vector.new(0,0,0),		-- rotate player so they sit facing the correct direction
	driver_attach_at = vector.new(0,0,0),		-- attach the driver at
	driver_eye_offset = vector.new(0,0,0),	-- offset for first person driver view
	number_of_passengers = 0,				-- maximum number of passengers. Can have 3 passengers maximum

	-- Attachment positions and offset for all passengers (can be over 3 passengers)
	passengers = {
		{
			attach_at = vector.new(0,0,0),
			eye_offset = vector.new(0,0,0),
		},
		{
			attach_at = vector.new(0,0,0),
			eye_offset = vector.new(0,0,0),
		},
		{
			attach_at = vector.new(0,0,0),
			eye_offset = vector.new(0,0,0),
		},
	},

	inventory_image = "filename.png",		-- image to use in inventory
	wield_image = "filename.png",			-- image to use in hand
	wield_scale = vector.new(1,1,1),		-- the size of the item in hand
	visual = "mesh",				-- what type of object (mesh, cube, etc...)
	mesh = "filename.ext",				-- mesh model to use
	textures = {"filename.png"},			-- mesh texture(s)
	visual_size = {x=1, y=1},			-- adjust vehicle size
	stepheight = 0,					-- what can the vehicle climb over?, 0.6 = climb slabs, 1.1 = climb nodes
	max_speed_forward = 10,				-- vehicle maximum forward speed
	max_speed_reverse = 5,				-- vehicle maximum reverse speed
	max_speed_upwards = 5,				-- vehicle maximum upwards speed (applies only if `can_fly` is enabled)
	max_speed_downwards = 3.5,			-- vehicle maximum downwards speed (applies only if `can_fly` is enabled)
	accel = 1,					-- how fast vehicle accelerates
	braking = 2,					-- how fast can the vehicle stop
	turn_speed = 2,					-- how quick can the vehicle turn
	drop_on_destroy = {""},				-- what gets dropped when vehicle is destroyed
	recipe = {},					-- crafting recipe
	-- HP/Armor stuff.
	min_hp = 1,
	max_hp = 10,
	armor = 25
}

-- nothing to change down here
vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
