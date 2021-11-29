
local name = "car_f1"
local definition = ...

definition.description = "F1 car"
-- adjust to change how vehicle reacts while driving
definition.max_speed_forward = 15
definition.max_speed_reverse = 7
definition.accel = 4
definition.braking = 8
definition.turn_speed = 4
definition.stepheight = 0.6
-- model specific stuff
definition.mesh = "car_f1.x"
definition.collisionbox = {-0.5, -0.4, -0.5, 0.5, 0.5, 0.5}
definition.onplace_position_adj = -0.1
definition.inventory_image = "car_f1_inventory.png"
definition.wield_image = "car_f1_wield.png"
definition.textures = {"car_f1.png"}
-- player specific stuff
definition.driver_attach_at = {x=0,y=0,z=0}
definition.drop_on_destroy = {"vehicle_mash:tire 2", "vehicle_mash:battery", "vehicle_mash:motor"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
