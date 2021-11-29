local euother = {
	{ "guideboard_left", "Guide Board (Left)", { white = 2, red = 2 } },
	{ "guideboard_right", "Guide Board (Right)", { white = 2, red = 2 } },
	{ "bendright", "Guide Sign in Bends", { white = 2, red = 2 } },
	{ "bendleft", "Guide Sign in Bends", { white = 2, red = 2 } },
	{ "pedestriansleft", "Pedestrians to the Left", { white = 2, black = 1 } },
	{ "pedestriansright", "Pedestrians to the Right", { white = 2, black = 1 } },
	{ "arrowright", "Right", { white = 2, black = 1 } },
	{ "arrowleft", "Left", { white = 2, black = 1 } },
	{ "arrowturnright", "Turn Right", { white = 2, black = 1 } },
	{ "arrowturnleft", "Turn Left", { white = 2, black = 1 } },
	{ "arrowshorizontal", "Both Directions Horizontal", { white = 2, black = 1 } },
	{ "arrowsvertical", "Both Directions Vertical", { white = 2, black = 1 } },
	{ "turningprioroad4", "Turning Priority Road (use screwdriver to rotate)", { white = 2, black = 1 } },
	{ "turningprioroad3-1", "Turning Priority Road (use screwdriver to rotate)", { white = 2, black = 1 } },
	{ "turningprioroad3-2", "Turning Priority Road (use screwdriver to rotate)", { white = 2, black = 1 } },
}

for k, v in pairs(euother) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euother",
		dye_needed = v[3]
	})
end


local euother_big = {
	{ "additionallane", "Additional Lane", { white = 3, black = 1 } },
	{ "mergelanes", "Merge Lanes", { white = 3, black = 1 } },
	{ "laneshift", "Lane Shift", { white = 3, black = 1 } },
	{ "transfertoothercarriageway1", "Transfer to other Carriageway (1 Lane)", { white = 3, black = 1 } },
	{ "transfertoothercarriageway2", "Transfer to other Carriageway (2 Lanes)", { white = 3, black = 1 } },
}

for k, v in pairs(euother_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euother",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end

minetest.register_alias("streets:sign_eu_guideboard", "streets:sign_eu_guideboard_right")
minetest.register_alias("streets:sign_eu_guideboard_center", "streets:sign_eu_guideboard_right_center")
minetest.register_alias("streets:sign_eu_guideboard_polemount", "streets:sign_eu_guideboard_right_polemount")