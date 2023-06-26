local euinfo = {
	{ "tunnel", "Tunnel", { blue = 2, white = 1, black = 1 } },
	{ "breakdownbay", "Breakdown Bay", { blue = 2, white = 1, black = 1 } },
	{ "highway", "Highway", { blue = 2, white = 1 } },
	{ "highwayend", "End of Highway", { blue = 2, white = 1, red = 1 } },
	{ "motorroad", "Motorroad", { blue = 2, white = 1 } },
	{ "motorroadend", "End of Motorroad", { blue = 2, white = 1, red = 1 } },
	{ "pedestriancrossing", "Pedestrian Crossing (Give Way!)", { blue = 2, white = 1, black = 1 } },
	{ "deadendstreet", "Dead End Street", { blue = 2, white = 1, red = 1 } },
	{ "firstaid", "First Aid", { blue = 2, white = 1, red = 1 } },
	{ "info", "Information Center", { blue = 2, white = 1, black = 1 } },
	{ "wc", "WC", { blue = 2, white = 1, black = 1 } },
	{ "parkingsite", "Parking Site", { blue = 2, white = 1 } },
}

for k, v in pairs(euinfo) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euinfo",
		dye_needed = v[3],
	})
end


local euinfo_big = {
	{ "trafficcalmingarea", "Traffic Calming Area", { blue = 3, white = 1 } },
	{ "trafficcalmingareaend", "End of Traffic Calming Area", { blue = 3, white = 1, red = 1 } },
	{ "exit", "Exit", { blue = 2, white = 1 } },
	{ "detourright", "Detour Right", { yellow = 2, black = 1 } },
	{ "detourleft", "Detour Left", { yellow = 2, black = 1 } },
	{ "detour", "Detour", { yellow = 2, black = 1 } },
	{ "detourend", "End of Detour", { yellow = 2, black = 1, red = 1 } },
}

for k, v in pairs(euinfo_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euinfo",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end