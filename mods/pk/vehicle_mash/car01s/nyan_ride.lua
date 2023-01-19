
local name = "car_nyan_ride"
local definition = ...

definition.description = "Nyan Ride car"
definition.inventory_image = "inv_car_pink.png"
definition.wield_image = "inv_car_pink.png"
definition.textures = {"nyan_ride.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
