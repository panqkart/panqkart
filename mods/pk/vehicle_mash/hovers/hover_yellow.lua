
local name = "hover_yellow"

local definition = ...

definition.description = "Yellow hovercraft"
definition.inventory_image = "hovercraft_yellow_inv.png"
definition.wield_image = "hovercraft_yellow_inv.png"
definition.textures = {"hovercraft_yellow.png"}
definition.drop_on_destroy = {"wool:yellow", "wool:black 2", "default:steelblock"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
