--- chunk functions
--

-- local vars for faster access
local char, encode_uint16, insert = string.char, modgen.encode_uint16, table.insert

function modgen.export_chunk(chunk_pos, filename)
	local min_mapblock, max_mapblock = modgen.get_mapblock_bounds_from_chunk(chunk_pos)
	local mapblocks = {}
	for z=min_mapblock.z,max_mapblock.z do
		for x=min_mapblock.x,max_mapblock.x do
			for y=min_mapblock.y,max_mapblock.y do
				local mapblock_pos = {x=x, y=y, z=z}
				local mapblock = modgen.serialize_mapblock(mapblock_pos)
				if not mapblock.empty then
					insert(mapblocks, mapblock)
				end
			end
		end
	end

	local data = modgen.create_chunk_data(mapblocks)
	if not data then
		-- no data
		return 0
	end

	modgen.write_chunk(data, filename)
	return #data
end

function modgen.create_chunk_data(mapblocks)
	if #mapblocks == 0 then
		return
	end

	-- header data (uncompressed)
	local header =
		-- 1 byte: version
		char(modgen.version) ..
		-- 1 byte: mapblock count
		char(#mapblocks) ..
		-- 4 bytes: mtime
		modgen.encode_uint32(os.time())

	-- main data (compressed)
	local data = {}

	-- node_ids
	for _, mapblock in ipairs(mapblocks) do
		local node_ids = mapblock.node_ids
		for i=1,#node_ids do
			insert(data, encode_uint16(node_ids[i]))
		end
	end

	-- param1
	for _, mapblock in ipairs(mapblocks) do
		local param1 = mapblock.param1
		for i=1,#param1 do
			insert(data, char(param1[i]))
		end
	end

	-- param2
	for _, mapblock in ipairs(mapblocks) do
		local param2 = mapblock.param2
		for i=1,#param2 do
			insert(data, char(param2[i]))
		end
	end

	local chunk_manifest = {
		-- mapblock metadata and absolute positions
		mapblocks = {},
		mtime = os.time()
	}

	for _, mapblock in ipairs(mapblocks) do
		local mapblock_manifest = {
			pos = mapblock.pos,
		}

		if mapblock.has_metadata then
			-- add metadata
			mapblock_manifest.metadata = mapblock.metadata
		end

		insert(chunk_manifest.mapblocks, mapblock_manifest)
	end

	local json = minetest.write_json(chunk_manifest)
	insert(data, json)

	return header .. minetest.compress(table.concat(data), "deflate")
end
