local eumandat = {
	{ "rightonly", "Right Only", { blue = 2, white = 1 } },
	{ "rightonly_", "Right Only", { blue = 2, white = 1 } },
	{ "leftonly", "Left Only", { blue = 2, white = 1 } },
	{ "leftonly_", "Left Only", { blue = 2, white = 1 } },
	{ "straightonly", "Straight Only", { blue = 2, white = 1 } },
	{ "straightrightonly", "Straight and Right Only", { blue = 2, white = 1 } },
	{ "straightleftonly", "Straight and Left Only", { blue = 2, white = 1 } },
	{ "roundabout", "Roundabout", { blue = 2, white = 1 } },
	{ "passingright", "Passing Right", { blue = 2, white = 1 } },
	{ "passingleft", "Passing Left", { blue = 2, white = 1 } },
	{ "busstation", "Busstation", { green = 2, yellow = 2 } },
	{ "cyclepath", "Cycle Path", { blue = 2, white = 1 } },
	{ "bridlepath", "Bridle Path", { blue = 2, white = 1 } },
	{ "walkway", "Walkway", { blue = 2, white = 1 } },
	{ "sharedpedestriansbicyclists", "Shared Way for Pedestrians and Bicyclists", { blue = 2, white = 1 } },
	{ "seperatedpedestriansbicyclists", "Seperated Way for Pedestrians and Bicyclists", { blue = 2, white = 1 } },
	{ "pedestrianszone", "Pedestrians Zone", { blue = 2, white = 2, black = 1 } },
	{ "pedestrianszoneend", "Pedestrians Zone", { grey = 2, white = 2, black = 1 } },
}

for k, v in pairs(eumandat) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "eumandat",
		dye_needed = v[3]
	})
end


local eumandat_big = {
	{ "onewayright", "One Way Road", { blue = 2, white = 1, black = 1 } },
	{ "onewayleft", "One Way Road", { blue = 2, white = 1, black = 1 } },
}

for k, v in pairs(eumandat_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "eumandat",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end