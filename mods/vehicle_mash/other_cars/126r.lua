
local name = "car_126r"
local definition = ...

definition.description = "126r car"
-- adjust to change how vehicle reacts while driving
definition.max_speed_forward = 12
definition.max_speed_reverse = 10
definition.accel = 3
definition.braking = 6
definition.turn_speed = 4
definition.stepheight = 1.1
-- model specific stuff
definition.mesh = "car_126r.x"
definition.collisionbox = {-0.7, -0.5, -0.7, 0.7, 0.7, 0.7}
definition.onplace_position_adj = 0
definition.inventory_image = "car_126r_inventory.png"
definition.wield_image = "car_126r_wield.png"
definition.textures = {"car_126r.png"}
-- player specific stuff
definition.driver_attach_at = {x=0,y=0,z=-4}
definition.drop_on_destroy = {"vehicle_mash:tire 2", "vehicle_mash:battery", "vehicle_mash:motor"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)
