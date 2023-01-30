local import_mod = ...

local modname = minetest.get_current_modname()
local MP = minetest.get_modpath(modname)

local function get_chunk_name(chunk_pos)
	return MP .. "/map/chunk_" .. chunk_pos.x .. "_" .. chunk_pos.y .. "_" .. chunk_pos.z .. ".bin"
end

function import_mod.read_chunk_header(chunk_pos)
	local filename = get_chunk_name(chunk_pos)
	local file = io.open(filename, "rb")
	if file then
		local version = string.byte(file:read(1))
		local mapblock_count = string.byte(file:read(1))
		local mtime = import_mod.decode_uint32(file:read(4), 0)
		return version, mapblock_count, mtime
	end
end

local function read_chunkdata(chunk_pos)
	local filename = get_chunk_name(chunk_pos)
	local file = io.open(filename, "rb")
	if file then
		local version = string.byte(file:read(1))
		local mapblock_count = string.byte(file:read(1))
		local mtime = import_mod.decode_uint32(file:read(4), 0)
		local data = file:read("*all")
		return version, mapblock_count, mtime, minetest.decompress(data, "deflate"), #data
	end
end

-- local vars for faster access
local insert, byte, decode_uint16 = table.insert, string.byte, import_mod.decode_uint16

function import_mod.load_chunk(chunk_pos, manifest)
	local version, mapblock_count, _, chunk_data = read_chunkdata(chunk_pos)
	if not chunk_data then
		-- write current os.time to modstorage
		import_mod.storage:set_int(minetest.pos_to_string(chunk_pos), os.time())
		return
	end
	if version ~= manifest.version then
		error("couldn't load chunk " .. minetest.pos_to_string(chunk_pos) ..
			" serialization-version: " .. version)
	end

	local manifest_offset = 1 + (4096 * 4 * mapblock_count)
	local chunk_manifest = minetest.parse_json(string.sub(chunk_data, manifest_offset))

	for mbi=1, mapblock_count do
		local mapblock_manifest = chunk_manifest.mapblocks[mbi]
		local mapblock = {
			node_ids = {},
			param1 = {},
			param2 = {},
			metadata = mapblock_manifest.metadata
		}

		for i=1,4096 do
			local node_id = decode_uint16(chunk_data, ((mbi-1) * 4096 * 2) + (i * 2) - 2)
			local param1 = byte(chunk_data, (4096 * 2 * mapblock_count) + ((mbi-1) * 4096) + i)
			local param2 = byte(chunk_data, (4096 * 3 * mapblock_count) + ((mbi-1) * 4096) + i)

			insert(mapblock.node_ids, node_id)
			insert(mapblock.param1, param1)
			insert(mapblock.param2, param2)
		end

		import_mod.localize_nodeids(manifest.node_mapping, mapblock.node_ids)
		import_mod.deserialize(mapblock, mapblock_manifest.pos)
	end

	if chunk_manifest.mtime then
		-- write emerge chunk mtime to modstorage
		import_mod.storage:set_int(minetest.pos_to_string(chunk_pos), chunk_manifest.mtime)
	end
end