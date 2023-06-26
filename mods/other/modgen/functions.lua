---------
-- common utility functions

-- copy environment to local scope
local env = ...

------
-- Mapblock position
-- @field x the x position in mapblocks
-- @field y the y position in mapblocks
-- @field z the z position in mapblocks
-- @table mapblock_pos


function modgen.sort_pos(pos1, pos2)
	pos1 = {x=pos1.x, y=pos1.y, z=pos1.z}
	pos2 = {x=pos2.x, y=pos2.y, z=pos2.z}
	if pos1.x > pos2.x then
		pos2.x, pos1.x = pos1.x, pos2.x
	end
	if pos1.y > pos2.y then
		pos2.y, pos1.y = pos1.y, pos2.y
	end
	if pos1.z > pos2.z then
		pos2.z, pos1.z = pos1.z, pos2.z
	end
	return pos1, pos2
end

--- returns the chunk position from a node position
-- @param pos the node-position
-- @return the chunk position
function modgen.get_chunkpos(pos)
	local mapblock_pos = modgen.get_mapblock(pos)
	local aligned_mapblock_pos = vector.add(mapblock_pos, 2)
	return vector.floor( vector.divide(aligned_mapblock_pos, 5) )
end

--- returns the lower and upper chunk bounds for the given position
-- @param pos the node-position
function modgen.get_chunk_bounds(pos)
	local chunk_pos = modgen.get_chunkpos(pos)
	local mapblock_min, mapblock_max = modgen.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = modgen.get_mapblock_bounds(mapblock_min)
	local _, max = modgen.get_mapblock_bounds(mapblock_max)
	return min, max
end

--- returns the chunk_bounds from a mapblock-position
-- @param mapblock_pos @{mapblock_pos}
-- @return the lower node-position
-- @return the upper node-position
function modgen.get_chunk_bounds_from_mapblock(mapblock_pos)
	local min = vector.multiply(mapblock_pos, 16)
	local max = vector.add(min, 15)
	return min, max
end

--- calculates the mapblock position from a node position
-- @param pos the node-position
-- @return @{mapblock_pos} the mapblock position
function modgen.get_mapblock(pos)
	return vector.floor( vector.divide(pos, 16))
end

function modgen.get_mapblock_bounds(pos)
	local mapblock = modgen.get_mapblock(pos)
	return modgen.get_mapblock_bounds_from_mapblock(mapblock)
end

function modgen.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = vector.subtract( vector.multiply(chunk_pos, 5), 2)
	local max = vector.add(min, 4)
	return min, max
end

function modgen.get_mapblock_bounds_from_mapblock(mapblock)
	local min = vector.multiply(mapblock, 16)
	local max = vector.add(min, 15)
	return min, max
end

function modgen.get_chunk_filename(chunk_pos)
	local map_dir = modgen.export_path .. "/map"
	return map_dir .. "/chunk_" ..
		chunk_pos.x .. "_" .. chunk_pos.y .. "_" .. chunk_pos.z .. ".bin"
end

function modgen.write_chunk(data, filename)
	local file = env.io.open(filename,"wb")
	if not file then
		error("could not open file: " .. filename)
	end
	file:write(data)
	if file and file:close() then
		return
	else
		error("write to '" .. filename .. "' failed!")
	end
end

function modgen.remove_chunk(chunk_pos)
	env.os.remove(modgen.get_chunk_filename(chunk_pos))
end

--- Returns the filesize of the specified file
-- @param filename the filename
-- @return the size in bytes or 0 if not found
function modgen.get_filesize(filename)
	local file = env.io.open(filename,"rb")
	if file then
		local size = file:seek("end")
		file:close()
		return size
	else
		return 0
	end
end

--- copies a files from the source to the target
-- @param src the source file
-- @param target the target file
function modgen.copyfile(src, target)
	local infile = env.io.open(src, "rb")
	local instr = infile:read("*a")
	infile:close()

	if not instr then
		return
	end

	local outfile, err = env.io.open(target, "wb")
	if not outfile then
		error("File " .. target .. " could not be opened for writing! " .. err or "")
	end
	outfile:write(instr)
	outfile:close()

	return #instr
end

--- copies the modgen-import skeleton to the specified patch
-- @param path the path to use
function modgen.write_mod_files(path)
	local basepath = modgen.MOD_PATH .. "/import_mod/"
	local files = minetest.get_dir_list(basepath, false)
	for _, filename in ipairs(files) do
		modgen.copyfile(basepath .. filename, path .. "/" .. filename)
	end
end


local ranges = {
	{ size=1000*1000, suffix="MB" },
	{ size=1000, suffix="kB" }
}

--- returns a formatted size as string
-- @param bytes the size in bytes
-- @return the formatted string
function modgen.pretty_size(bytes)
	for _, range in ipairs(ranges) do
		if bytes > range.size then
			return (math.floor(bytes / range.size * 100) / 100) .. " " .. range.suffix
		end
	end
	return bytes .. " bytes"
end

--- updates the boundaries max- and min-positions
function modgen.update_bounds(current_pos, bounds)
	for _, axis in ipairs({"x","y","z"}) do
		if current_pos[axis] < bounds.min[axis] then
			bounds.min[axis] = current_pos[axis]
		end
		if current_pos[axis] > bounds.max[axis] then
			bounds.max[axis] = current_pos[axis]
		end
	end
end

-- mapping from local node-id to export-node-id
local external_node_id_mapping = {}

--- returns the localized nodeid from the manifest or adds a new one
function modgen.get_nodeid(node_id, manifest)
	if not external_node_id_mapping[node_id] then
		-- lookup node_id
		local nodename = minetest.get_name_from_content_id(node_id)

		if not manifest.node_mapping[nodename] then
			-- mapping does not exist yet, create it
			manifest.node_mapping[nodename] = manifest.next_id
			external_node_id_mapping[node_id] = manifest.next_id

			-- increment next external id
			manifest.next_id = manifest.next_id + 1
		else
			-- mapping exists, look it up
			local external_id = manifest.node_mapping[nodename]
			external_node_id_mapping[node_id] = external_id
		end
	end

	return external_node_id_mapping[node_id]
end
