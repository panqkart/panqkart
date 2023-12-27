local import_mod = ...

function import_mod.get_mapblock_pos(pos)
	return vector.floor( vector.divide(pos, 16))
end

function import_mod.get_mapblock(pos)
	return vector.floor( vector.divide(pos, 16))
end

function import_mod.get_chunkpos(pos)
	local mapblock_pos = import_mod.get_mapblock_pos(pos)
	local aligned_mapblock_pos = vector.add(mapblock_pos, 2)
	return vector.floor( vector.divide(aligned_mapblock_pos, 5) )
end

function import_mod.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = vector.subtract( vector.multiply(chunk_pos, 5), 2)
	local max = vector.add(min, 4)
	return min, max
end

function import_mod.get_chunk_bounds(pos)
	local chunk_pos = import_mod.get_chunkpos(pos)
	local mapblock_min, mapblock_max = import_mod.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = import_mod.get_mapblock_bounds(mapblock_min)
	local _, max = import_mod.get_mapblock_bounds(mapblock_max)
	return min, max
end

function import_mod.get_mapblock_bounds_from_mapblock(mapblock)
	local min = vector.multiply(mapblock, 16)
	local max = vector.add(min, 15)
	return min, max
end

function import_mod.get_mapblock_bounds(pos)
	local mapblock = import_mod.get_mapblock(pos)
	return import_mod.get_mapblock_bounds_from_mapblock(mapblock)
end