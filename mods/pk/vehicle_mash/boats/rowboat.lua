
local name = "rowboat"
local definition = ...
local craft_check = minetest.settings:get_bool("vehicle_mash.enable_crafts")

definition.description = "Rowboat"
definition.inventory_image = "rowboat_inventory.png"
definition.wield_image = "rowboat_wield.png"
definition.mesh = "rowboat.x"
definition.drop_on_destroy = {"default:wood 4"}

if craft_check or craft_check == nil then
	definition.recipe = {
		{"",			"",				""},
		{"group:wood",	"",				"group:wood"},
		{"group:wood",	"group:wood",	"group:wood"}
	}
end

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
