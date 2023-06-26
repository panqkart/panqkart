

minetest.register_chatcommand("autosave", {
	func = function(_, params)
		if params == "on" then
			modgen.autosave = true
			modgen.storage:set_int("autosave", 1)
			return true, "Autosave enabled"
		else
			modgen.autosave = false
			modgen.storage:set_int("autosave", 0)
			return true, "Autosave disabled"
		end
	end
})
