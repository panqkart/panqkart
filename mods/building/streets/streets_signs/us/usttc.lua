local usttc = {
	{ "exitclosed", "Exit Closed", { orange = 3, black = 3 } },
	{ "roadclosed", "Road Closed", { white = 3, black = 2 } },
	{ "roadclosedahead", "Road Closed Ahead", { orange = 3, black = 3 } },
	{ "roadclosedtothrutraffic", "Road Closed to Thru Traffic", { white = 3, black = 3 } },
	{ "roadworkahead", "Road Work Ahead", { orange = 3, black = 3 } },
	{ "utilityworkahead", "Utility Work Ahead", { orange = 3, black = 3 } },
}

for k, v in pairs(usttc) do
	streets.register_road_sign({
		name = "sign_us_" .. v[1],
		friendlyname = v[2] .. " Sign",
		tiles = {
			"streets_sign_us_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "usttc",
		dye_needed = v[3]
	})
end