
local name = "mesecar_pink"
local definition = ...

definition.description = "Pink Mesecar"
definition.inventory_image = "mesecar_car3front.png"
definition.wield_image = "mesecar_car3front.png"
definition.textures = {
	"mesecar_car3top.png",
	"mesecar_carbase.png",
	"mesecar_car3rightside.png",
	"mesecar_car3leftside.png",
	"mesecar_car3front.png",
	"mesecar_car3back.png"
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
