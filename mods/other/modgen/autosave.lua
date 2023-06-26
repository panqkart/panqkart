

-- list of chunks marked for export
local chunks = {}

-- autosave worker function
local function worker()
	local count = 0
	for hash in pairs(chunks) do
		count = count + 1
		local chunk_pos = minetest.get_position_from_hash(hash)
		local mapblock_pos = modgen.get_mapblock_bounds_from_chunk(chunk_pos)
		local min = modgen.get_mapblock_bounds_from_mapblock(mapblock_pos)
		modgen.export("singleplayer", min, min, true, false, function(stats)
			local sign = stats.bytes > 0 and "+" or ""
			minetest.chat_send_all("[modgen] Changed: " .. sign .. stats.bytes .. " bytes in " .. stats.millis .. " ms")
		end)
	end

	if count > 0 then
		minetest.chat_send_all("[modgen] Dispatched " .. count .. " chunk(s) to export")
	end
	chunks = {}
	minetest.after(2, worker)
end

minetest.after(1, worker)

--- marks a region as changed, to be used by dependent mods whose changes don't get caught
--- by the usual change-detection
-- @param pos1 the first position of the changed region
-- @param pos2 the second position of the changed region
function modgen.mark_changed(pos1, pos2)
	if not modgen.autosave then
		return
	end

	if not pos2 then
		-- default to same pos2 as pos1
		pos2 = pos1
	end

	pos1, pos2 = modgen.sort_pos(pos1, pos2)

	local chunk_pos1 = modgen.get_chunkpos(pos1)
	local chunk_pos2 = modgen.get_chunkpos(pos2)
	for x=chunk_pos1.x,chunk_pos2.x do
		for y=chunk_pos1.y,chunk_pos2.y do
			for z=chunk_pos1.z,chunk_pos2.z do
				local chunk_pos = {x=x, y=y, z=z}
				local hash = minetest.hash_node_position(chunk_pos)
				chunks[hash] = true
			end
		end
	end
end

-- autosave on minetest.set_node
local old_set_node = minetest.set_node
function minetest.set_node(pos, node)
	modgen.mark_changed(pos)
	return old_set_node(pos, node)
end

-- autosave on minetest.swap_node
local old_swap_node = minetest.swap_node
function minetest.swap_node(pos, node)
	modgen.mark_changed(pos)
	return old_swap_node(pos, node)
end

-- autosave on place/dignode
local function place_dig_callback(pos)
	modgen.mark_changed(pos)
end
minetest.register_on_placenode(place_dig_callback)
minetest.register_on_dignode(place_dig_callback)

-- autosave on we commands
if minetest.get_modpath("worldedit") then
	-- used by various primitives and commands
	local old_mapgenhelper_init = worldedit.manip_helpers.init
	worldedit.manip_helpers.init = function(pos1, pos2)
		modgen.mark_changed(pos1, pos2)
		return old_mapgenhelper_init(pos1, pos2)
	end

	-- used by //load and others
	local old_keeploaded = worldedit.keep_loaded
	worldedit.keep_loaded = function(pos1, pos2)
		modgen.mark_changed(pos1, pos2)
		return old_keeploaded(pos1, pos2)
	end

	-- //fixlight
	local old_fixlight = worldedit.fixlight
	worldedit.fixlight = function(pos1, pos2)
		modgen.mark_changed(pos1, pos2)
		return old_fixlight(pos1, pos2)
	end
end

-- intercept various node-based events
minetest.register_on_mods_loaded(function()
	for nodename, def in pairs(minetest.registered_nodes) do
		if type(def.on_receive_fields) == "function" then
			-- intercept formspec events
			local old_on_receive_fields = def.on_receive_fields
			minetest.override_item(nodename, {
				on_receive_fields = function(pos, formname, fields, sender)
					modgen.mark_changed(pos)
					return old_on_receive_fields(pos, formname, fields, sender)
				end
			})
		end

		if type(def.on_metadata_inventory_move) == "function" then
			-- intercept inv move event
			local old_inv_move = def.on_metadata_inventory_move
			minetest.override_item(nodename, {
				on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
					modgen.mark_changed(pos)
					return old_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
				end
			})
		end

		if type(def.on_metadata_inventory_put) == "function" then
			-- intercept inv put event
			local old_inv_put = def.on_metadata_inventory_put
			minetest.override_item(nodename, {
				on_metadata_inventory_put = function(pos, listname, index, stack, player)
					modgen.mark_changed(pos)
					return old_inv_put(pos, listname, index, stack, player)
				end
			})
		end

		if type(def.on_metadata_inventory_take) == "function" then
			-- intercept inv take event
			local old_inv_take = def.on_metadata_inventory_take
			minetest.override_item(nodename, {
				on_metadata_inventory_take = function(pos, listname, index, stack, player)
					modgen.mark_changed(pos)
					return old_inv_take(pos, listname, index, stack, player)
				end
			})
		end

	end
end)

if minetest.get_modpath("screwdriver2") and minetest.registered_items["screwdriver2:screwdriver"] then
	local old_nodedef = minetest.registered_items["screwdriver2:screwdriver"]
	local old_on_use = old_nodedef.on_use
	local old_on_place = old_nodedef.on_place

	local function handle_pointed_thing(pointed_thing)
		if pointed_thing.above then
			modgen.mark_changed(pointed_thing.above)
		end
		if pointed_thing.under then
			modgen.mark_changed(pointed_thing.under)
		end
	end

	minetest.override_item("screwdriver2:screwdriver", {
		on_use = function(itemstack, player, pointed_thing)
			handle_pointed_thing(pointed_thing)
			return old_on_use(itemstack, player, pointed_thing)
		end,
		on_place = function(itemstack, player, pointed_thing)
			handle_pointed_thing(pointed_thing)
			return old_on_place(itemstack, player, pointed_thing)
		end
	})
end