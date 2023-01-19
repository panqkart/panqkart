
local name = "car_blue"
local definition = ...

definition.description = "Blue car"
definition.inventory_image = "inv_car_blue.png"
definition.wield_image = "inv_car_blue.png"
definition.textures = {"car_blue.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
