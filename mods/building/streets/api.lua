--[[
	## StreetsMod 2.0 ##
	Submod: streetsmod
	Optional: false
	Category: Init
]]

function streets.copytable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[streets.copytable(orig_key)] = streets.copytable(orig_value)
		end
		setmetatable(copy, streets.copytable(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

function streets.load_submod(dirname)
	dofile(streets.conf.modpath .. "/" .. dirname .. "/init.lua")
	-- The function below had to be replaced by the line above
	-- to make the streets mod work with minetest commit 2ff054d

	-- Check whether submod's init file exists
	--[[local f = io.open(streets.conf.modpath .. "/" .. dirname .. "/init.lua")
	if f ~= nil then
		-- Load it
		f.close()
		dofile(streets.conf.modpath .. "/" .. dirname .. "/init.lua")
	else
		minetest.log("error", "[Streets] '" .. dirname .. "' does not exist")
	end]]
end

function streets.register_road_surface(data)
	streets.surfaces.surfacetypes["streets:" .. data.name] = data
end

function streets.register_road_sign(data)
	if data.type == "minetest" or data.type == "normal" or data.type == "big" then
		streets.signs.signtypes["streets:" .. data.name] = data
	end
end

function streets.register_road_marking(data)
	streets.labels.labeltypes[data.name] = data
end
