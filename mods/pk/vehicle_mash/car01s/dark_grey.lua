
local name = "car_dark_grey"
local definition = ...

definition.description = "Dark grey car"
definition.inventory_image = "inv_car_dark_grey.png"
definition.wield_image = "inv_car_dark_grey.png"
definition.textures = {"car_dark_grey.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
