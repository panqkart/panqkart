local import_mod = ...

local air_content_id = minetest.get_content_id("air")

-- local nodename->id cache
local local_nodename_to_id_mapping = {} -- name -> id

function import_mod.localize_nodeids(node_mapping, node_ids)
	local foreign_nodeid_to_name_mapping = {} -- id -> name
	for k, v in pairs(node_mapping) do
		foreign_nodeid_to_name_mapping[v] = k
	end

	for i, node_id in ipairs(node_ids) do
		local node_name = foreign_nodeid_to_name_mapping[node_id]
		local local_node_id = local_nodename_to_id_mapping[node_name]
		if not local_node_id then
			if minetest.registered_nodes[node_name] then
				-- node is locally available
				local_node_id = minetest.get_content_id(node_name)
			else
				-- node is not available here
				-- TODO: make replacements configurable
				local_node_id = air_content_id
			end
			local_nodename_to_id_mapping[node_name] = local_node_id

		end

		node_ids[i] = local_node_id
	end
end
