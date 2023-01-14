
local name = "car_green"
local definition = ...

definition.description = "Green car"
definition.inventory_image = "inv_car_green.png"
definition.wield_image = "inv_car_green.png"
definition.textures = {"car_green.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
