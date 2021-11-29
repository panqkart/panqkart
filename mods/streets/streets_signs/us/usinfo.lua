local usinfo = {
	{ "arrow_exitgore", "Exit Gore Arrow", { green = 4, white = 2 } },
	{ "pushtocross_left", "Push to Cross (Left)", { white = 3, black = 3 } },
	{ "pushtocross_right", "Push to Cross (Right)", { white = 3, black = 3 } },
}

for k, v in pairs(usinfo) do
	streets.register_road_sign({
		name = "sign_us_" .. v[1],
		friendlyname = v[2] .. " Sign",
		tiles = {
			"streets_sign_us_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "usinfo",
		dye_needed = v[3]
	})
end