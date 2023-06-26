
minetest.register_chatcommand("export_here", {
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local ppos = player:get_pos()
		local radius = tonumber(params) or 100
		local pos1 = vector.subtract(ppos, radius)
		local pos2 = vector.add(ppos, radius)

		modgen.export(name, pos1, pos2, params == "fast", true)

		return true, "Export started with radius " .. radius .. "!"
	end
})
