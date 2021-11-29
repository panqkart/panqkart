
local name = "mesecar_purple"
local definition = ...

definition.description = "Purple Mesecar"
definition.inventory_image = "mesecar_car2front.png"
definition.wield_image = "mesecar_car2front.png"
definition.textures = {
	"mesecar_car2top.png",
	"mesecar_carbase.png",
	"mesecar_car2rightside.png",
	"mesecar_car2leftside.png",
	"mesecar_car2front.png",
	"mesecar_car2back.png"
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
