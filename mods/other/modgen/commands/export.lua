
minetest.register_chatcommand("export", {
	func = function(name, params)

		local pos1 = modgen.get_pos(1, name)
		local pos2 = modgen.get_pos(2, name)

		if not pos1 or not pos2 then
			return false, "you need to set /pos1 and /pos2 first!"
		end

		-- sort by lower position first
		pos1, pos2 = modgen.sort_pos(pos1, pos2)

		modgen.export(name, pos1, pos2, params == "fast", true)

		return true, "Export started!"
	end
})
