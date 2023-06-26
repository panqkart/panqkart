local euwarn = {
	{ "danger", "Danger", { red = 2, white = 2, black = 1 } },
	{ "twowaytraffic", "Two-Way Traffic", { red = 2, white = 2, black = 1 } },
	{ "trafficlightahead", "Trafficlight Ahead", { red = 3, white = 2, yellow = 1, green = 1 } },
	{ "farmanimals", "Farm Animals", { red = 2, white = 2, black = 1 } },
	{ "intersectionrightofwayright", "intersection with right of way from the right", { red = 2, white = 2, black = 1 } },
	{ "curveleft", "Curve Left", { red = 2, white = 2, black = 1 } },
	{ "curveright", "Curve Right", { red = 2, white = 2, black = 1 } },
	{ "doublecurveleft", "Double Curve Left", { red = 2, white = 2, black = 1 } },
	{ "doublecurveright", "Double Curve Right", { red = 2, white = 2, black = 1 } },
	{ "downhillgrade", "Downhill Grade", { red = 2, white = 2, black = 2 } },
	{ "uphillgrade", "Uphill Grade", { red = 2, white = 2, black = 2 } },
	{ "bumpyroad", "Bumpy Road", { red = 2, white = 2, black = 1 } },
	{ "slipdanger", "Slip Danger", { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsboth", "Road Narrow on Both Sides", { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsleft", "Road Narrow on Left Side", { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsright", "Road Narrow on Right Side", { red = 2, white = 2, black = 1 } },
	{ "roadworks", "Road Works", { red = 2, white = 2, black = 1 } },
	{ "jam", "Jam", { red = 2, white = 2, black = 1 } },
	{ "pedestrians", "Pedestrians", { red = 2, white = 2, black = 1 } },
	{ "children", "Children", { red = 2, white = 2, black = 1 } },
	{ "bikes", "Bikes", { red = 2, white = 2, black = 1 } },
	{ "deercrossing", "Deer Crossing", { red = 2, white = 2, black = 1 } },
	{ "busses", "Busses", { red = 2, white = 2, black = 1 } },
	{ "railroadcrossing", "Railroad Crossing", { red = 2, white = 2, black = 1 } },
}

for k, v in pairs(euwarn) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euwarn",
		dye_needed = v[3]
	})
end