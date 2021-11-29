
local name = "mesecar_blue"
local definition = ...

definition.description = "Blue Mesecar"
definition.inventory_image = "mesecar_car1front.png"
definition.wield_image = "mesecar_car1front.png"
definition.textures = {
	"mesecar_car1top.png",
	"mesecar_carbase.png",
	"mesecar_car1rightside.png",
	"mesecar_car1leftside.png",
	"mesecar_car1front.png",
	"mesecar_car1back.png"
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
