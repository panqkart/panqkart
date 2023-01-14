
local name = "car_violet"
local definition = ...

definition.description = "Violet car"
definition.inventory_image = "inv_car_violet.png"
definition.wield_image = "inv_car_violet.png"
definition.textures = {"car_violet.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
