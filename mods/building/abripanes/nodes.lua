local panes_list = {
	{"white", "White", "ffffff", }, {"blue", "Blue", "0000FF", },
	{"cyan", "Cyan", "00FFFF", }, {"green", "Green", "00FF00", },
	{"magenta", "Magenta", "FF00FF", }, {"orange", "Orange", "FF6103", },
	{"violet", "Purple", "800080", }, {"red", "Red", "FF0000", },
	{"yellow", "Yellow", "FFFF00", },
}

for i in ipairs(panes_list) do
	local name = panes_list[i][1]
	local description = panes_list[i][2]
	local colour = panes_list[i][3]
	local tex = "abriglass_plainglass.png^[colorize:#"..colour..":122"

	abripanes.register_pane("abriglass_pane_"..name, {
		description = description.." Glass Pane",
		textures = {tex, tex, tex},
		groups = {cracky = 3},
		use_texture_alpha = "blend",
		wield_image = tex,
		inventory_image = tex,
		sounds = default.node_sound_glass_defaults(),
		recipe = {
			{"default:glass", "default:glass", "default:glass",},
			{"default:glass", "default:glass", "default:glass",},
			{"","dye:"..name,"",},
		}
	})
end