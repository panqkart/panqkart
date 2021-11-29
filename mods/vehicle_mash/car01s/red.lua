
local name = "car_red"
local definition = ...

definition.description = "Red car"
definition.inventory_image = "inv_car_red.png"
definition.wield_image = "inv_car_red.png"
definition.textures = {"car_red.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
