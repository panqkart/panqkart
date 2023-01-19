
local name = "car_brown"
local definition = ...

definition.description = "Brown car"
definition.inventory_image = "inv_car_brown.png"
definition.wield_image = "inv_car_brown.png"
definition.textures = {"car_brown.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
