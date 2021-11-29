
local name = "car_oerkki_bliss"
local definition = ...

definition.description = "Oerkki Bliss car"
definition.inventory_image = "inv_car_black.png"
definition.wield_image = "inv_car_black.png"
definition.textures = {"oerkki_bliss.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
