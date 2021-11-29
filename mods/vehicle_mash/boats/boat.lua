
local name = "boat"
local definition = ...
local craft_check = minetest.settings:get_bool("vehicle_mash.enable_crafts")

definition.description = "BoatA"
definition.inventory_image = "boat_inventory.png"
definition.wield_image = "boat_wield.png"
definition.mesh = "boats_boat.obj"
definition.drop_on_destroy = {"default:wood 3"}

if craft_check or craft_check == nil then
	definition.recipe = {
		{"",			"",				""},
		{"",			"",				"group:wood"},
		{"group:wood",	"group:wood",	"group:wood"}
	}
end

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
