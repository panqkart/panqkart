------------------------
-- Crafts/craftitems --
------------------------

-- Car parts
minetest.register_craftitem("vehicle_mash:motor", {
	description = "Motor",
	inventory_image = "motor.png"
})

minetest.register_craftitem("vehicle_mash:tire", {
	description = "Tire",
	inventory_image = "tire.png"
})

minetest.register_craftitem("vehicle_mash:windshield", {
	description = "Wind Shield",
	inventory_image = "windshield.png"
})

minetest.register_craftitem("vehicle_mash:battery", {
    description = "Car battery",
    inventory_image = "battery.png"
})

minetest.register_craft({
    output = "vehicle_mash:motor",
    recipe = {
        {"default:copper_ingot", "default:steel_ingot", "default:copper_ingot"},
		{"default:steel_ingot", "default:steelblock", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    }
})

minetest.register_craft({
    output = "vehicle_mash:tire",
    recipe = {
        {"wool:dark_grey", "wool:dark_grey", "wool:dark_grey"},
		{"wool:dark_grey", "default:steelblock", "wool:dark_grey"},
		{"wool:dark_grey", "wool:dark_grey", "wool:dark_grey"},
    }
})

minetest.register_craft({
    output = "vehicle_mash:windshield",
    recipe = {
        {"default:stone", "default:stone", "default:stone"},
		{"default:stone", "xpanes:pane_flat", "default:stone"},
		{"default:stone", "default:stone", "default:stone"},
    }
})

minetest.register_craft({
    output = "vehicle_mash:battery",
    recipe = {
        {"wool:blue", "", "wool:red"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"wool:dark_grey", "default:steelblock", "wool:dark_grey"},
    }
})

-- Hovercrafts
minetest.register_craft({
	output = "vehicle_mash:hover_red",
	recipe = {
		{"", "", "default:steelblock"},
		{"wool:red", "wool:red", "wool:red"},
		{"wool:black", "wool:black", "wool:black"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:hover_blue",
	recipe = {
		{"", "", "default:steelblock"},
		{"wool:blue", "wool:blue", "wool:blue"},
		{"wool:black", "wool:black", "wool:black"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:hover_green",
	recipe = {
		{"", "", "default:steelblock"},
		{"wool:green", "wool:green", "wool:green"},
		{"wool:black", "wool:black", "wool:black"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:hover_yellow",
	recipe = {
		{"", "", "default:steelblock"},
		{"wool:yellow", "wool:yellow", "wool:yellow"},
		{"wool:black", "wool:black", "wool:black"},
	}
})

-- Mese cars
minetest.register_craft({
	output = "vehicle_mash:mesecar_blue",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"vehicle_mash:motor", "vehicle_mash:battery", "vehicle_mash:motor"},
	},
})

minetest.register_craft({
	output = "vehicle_mash:mesecar_purple",
	recipe = {
		{"default:steel_ingot", "dye:magenta", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"vehicle_mash:motor", "vehicle_mash:battery", "vehicle_mash:motor"},
	},
})

minetest.register_craft({
	output = "vehicle_mash:mesecar_pink",
	recipe = {
		{"default:steel_ingot", "dye:pink", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"vehicle_mash:motor", "vehicle_mash:battery", "vehicle_mash:motor"},
	},
})

minetest.register_craft({
	output = "vehicle_mash:mesecar_yellow",
	recipe = {
		{"default:steel_ingot", "dye:yellow", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"vehicle_mash:motor", "vehicle_mash:battery", "vehicle_mash:motor"},
	},
})

-- CAR01's
minetest.register_craft({
	output = "vehicle_mash:car_black",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:black", "vehicle_mash:motor", "wool:black"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_blue",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:blue", "vehicle_mash:motor", "wool:blue"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_brown",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:brown", "vehicle_mash:motor", "wool:brown"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_cyan",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:cyan", "vehicle_mash:motor", "wool:cyan"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_dark_green",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:dark_green", "vehicle_mash:motor", "wool:dark_green"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_dark_grey",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:dark_grey", "vehicle_mash:motor", "wool:dark_grey"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_green",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:green", "vehicle_mash:motor", "wool:green"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_grey",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:grey", "vehicle_mash:motor", "wool:grey"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_magenta",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:magenta", "vehicle_mash:motor", "wool:magenta"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_orange",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:orange", "vehicle_mash:motor", "wool:orange"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_pink",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:pink", "vehicle_mash:motor", "wool:pink"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_red",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:red", "vehicle_mash:motor", "wool:red"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_violet",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:violet", "vehicle_mash:motor", "wool:violet"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_white",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:white", "vehicle_mash:motor", "wool:white"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_yellow",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:yellow", "vehicle_mash:motor", "wool:yellow"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_hot_rod",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:red", "vehicle_mash:motor", "wool:orange"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_nyan_ride",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:pink", "vehicle_mash:motor", "wool:grey"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_oerkki_bliss",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:grey", "vehicle_mash:motor", "wool:black"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_road_master",
	recipe = {
		{"vehicle_mash:tire", "vehicle_mash:windshield", "vehicle_mash:tire"},
		{"wool:brown", "vehicle_mash:motor", "wool:black"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

-- Other cars
minetest.register_craft({
	output = "vehicle_mash:car_f1",
	recipe = {
		{"vehicle_mash:tire", "", "vehicle_mash:tire"},
		{"vehicle_mash:motor", "wool:red", "vehicle_mash:motor"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})

minetest.register_craft({
	output = "vehicle_mash:car_126r",
	recipe = {
		{"vehicle_mash:tire", "xpanes:obsidian_pane_flat", "vehicle_mash:tire"},
		{"vehicle_mash:motor", "wool:red", "vehicle_mash:motor"},
		{"vehicle_mash:tire", "vehicle_mash:battery", "vehicle_mash:tire"},
	}
})
