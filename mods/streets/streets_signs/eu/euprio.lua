local euprio = {
	{ "yield", "Yield", { white = 2, red = 2 } },
	{ "stop", "Stop", { white = 1, red = 3 } },
	{ "givewayoncoming", "Give Way to Oncoming Traffic", { white = 2, red = 2, black = 1 } },
	{ "priooveroncoming", "Priority over Oncoming Traffic", { white = 1, red = 1, blue = 2 } },
	{ "rightofway", "Right of Way on the Next Crossing", { white = 2, red = 2, black = 1 } },
	{ "majorroad", "Major Road", { white = 2, yellow = 2 } },
	{ "endmajorroad", "End of Major Road", { white = 2, yellow = 2, black = 1 } },
	{ "greenarrow", "Green Arrow (Right Turn on Red Allowed)", { green = 2, black = 2 } },
}

for k, v in pairs(euprio) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euprio",
		dye_needed = v[3]
	})
end


local euprio_big = {
	{ "standrews", "St. Andrews Cross", { white = 2, red = 1 } },
}

for k, v in pairs(euprio_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euprio",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end