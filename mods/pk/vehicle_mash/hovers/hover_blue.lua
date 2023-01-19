
local name = "hover_blue"

local definition = ...

definition.description = "Blue hovercraft"
definition.inventory_image = "hovercraft_blue_inv.png"
definition.wield_image = "hovercraft_blue_inv.png"
definition.textures = {"hovercraft_blue.png"}
definition.drop_on_destroy = {"wool:blue", "wool:black 2", "default:steelblock"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
