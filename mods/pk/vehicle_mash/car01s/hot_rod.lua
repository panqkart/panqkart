
local name = "car_hot_rod"
local definition = ...

definition.description = "Hot Rod car"
definition.inventory_image = "inv_car_red.png"
definition.wield_image = "inv_car_red.png"
definition.textures = {"hot_rod.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
