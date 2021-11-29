
local name = "car_black"
local definition = ...

definition.description = "Black car"
definition.inventory_image = "inv_car_black.png"
definition.wield_image = "inv_car_black.png"
definition.textures = {"car_black.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
