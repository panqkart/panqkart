
local name = "car_road_master"
local definition = ...

definition.description = "Road Master car"
definition.inventory_image = "inv_car_brown.png"
definition.wield_image = "inv_car_brown.png"
definition.textures = {"road_master.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
