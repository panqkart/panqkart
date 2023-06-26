
minetest.register_chatcommand("pos1", {
	description = "Set position 1",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = vector.round(player:get_pos())
			modgen.set_pos(1, name, pos)
		end
	end
})

minetest.register_chatcommand("pos2", {
	description = "Set position 2",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = vector.round(player:get_pos())
			modgen.set_pos(2, name, pos)
		end
	end
})
