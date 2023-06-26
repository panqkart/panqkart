local usom = {
	{ "om1", "Object Marker Type 1", { yellow = 5 } },
	{ "om2", "Object Marker Type 2", { yellow = 2 } },
	{ "om3l", "Object Marker Type 3 (Left)", { yellow = 3, black = 3 } },
	{ "om3c", "Object Marker Type 3 (Center)", { yellow = 3, black = 3 } },
	{ "om3r", "Object Marker Type 3 (Right)", { yellow = 3, black = 3 } },
	{ "om4", "Object Marker Type 4", { red = 5 } },
}

for k, v in pairs(usom) do
	streets.register_road_sign({
		name = "sign_us_" .. v[1],
		friendlyname = v[2] .. " Sign",
		tiles = {
			"streets_sign_us_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "usom",
		dye_needed = v[3]
	})
end

