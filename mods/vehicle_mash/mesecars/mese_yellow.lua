
local name = "mesecar_yellow"
local definition = ...

definition.description = "Yellow Mesecar"
definition.inventory_image = "mesecar_car4front.png"
definition.wield_image = "mesecar_car4front.png"
definition.textures = {
	"mesecar_car4top.png",
	"mesecar_carbase.png",
	"mesecar_car4rightside.png",
	"mesecar_car4leftside.png",
	"mesecar_car4front.png",
	"mesecar_car4back.png"
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
