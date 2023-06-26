local euprohib = {
	{ "novehicles", "No Vehicles", { red = 2, white = 2 } },
	{ "nomotorcars", "No Motorcars", { red = 2, white = 1, black = 1 } },
	{ "notrucks", "No Trucks", { red = 2, white = 1, black = 1 } },
	{ "nobikes", "No Bikes", { red = 2, white = 1, black = 1 } },
	{ "nopedestrians", "No Pedestrians", { red = 2, white = 1, black = 1 } },
	{ "nohorsebackriding", "No Horseback Riding", { red = 2, white = 1, black = 1 } },
	{ "nomotorvehicles", "No Motor Vehicles", { red = 2, white = 1, black = 1 } },
	{ "noentry", "No Entry", { red = 3, white = 1 } },
	{ "nouturns", "No U Turns", { red = 2, white = 1, black = 1 } },
	{ "30zone", "30 km/h Zone", { red = 2, white = 1, black = 1 } },
	{ "30zoneend", "End of 30 km/h Zone", { grey = 2, white = 1, black = 1 } },
	{ "noovertaking", "No Overtaking", { red = 2, white = 1, black = 1 } },
	{ "endnoovertaking", "End of No Overtaking", { grey = 2, white = 1, black = 1 } },
	{ "end", "End of Speed and Overtaking Limitations", { white = 2, black = 1 } },
	{ "noparking", "No Parking", { red = 2, blue = 2 } },
	{ "nostopping", "No Stopping and Parking", { red = 2, blue = 2 } },
	{ "10", "10 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
	{ "30", "30 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
	{ "50", "50 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
	{ "70", "70 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
	{ "100", "100 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
	{ "120", "120 km/h Speed Limit", { red = 2, white = 1, black = 1 } },
}

for k, v in pairs(euprohib) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euprohib",
		dye_needed = v[3]
	})
end