local import_mod = ...

function import_mod.nodename_check(manifest)
	-- assemble node-list from registered lbm's
	local lbm_nodes = {}
	for _, lbm in ipairs(minetest.registered_lbms) do
		if type(lbm.nodenames) == "string" then
			-- duh, list as string
			lbm_nodes[lbm.nodenames] = true
		else
			-- proper list, add all regardless if they are a "group:*"
			for _, nodename in ipairs(lbm.nodenames) do
				lbm_nodes[nodename] = true
			end
		end
	end

	for nodename in pairs(manifest.node_mapping) do
		if not minetest.registered_nodes[nodename]
				and not minetest.registered_aliases[nodename]
				and not lbm_nodes[nodename] then
					error("node not found and not aliased: " .. nodename)
		end
	end
end