
local name = "car_grey"
local definition = ...

definition.description = "Grey car"
definition.inventory_image = "inv_car_grey.png"
definition.wield_image = "inv_car_grey.png"
definition.textures = {"car_grey.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
