local import_mod = ...

local function get_mod_chunk_mtime(chunk_pos)
    local _,_,mtime = import_mod.read_chunk_header(chunk_pos)
    return mtime
end

local function get_world_chunk_mtime(chunk_pos)
    local mtime = import_mod.storage:get_int(minetest.pos_to_string(chunk_pos))
    if mtime == 0 then
        return nil
    else
        return mtime
    end
end

local cache = {}
local function check_player_pos(player)
    local ppos = player:get_pos()
    local chunk_pos = import_mod.get_chunkpos(ppos)

    -- cache access
    local cache_key = minetest.pos_to_string(chunk_pos)
    if cache[cache_key] then
        return
    end
    cache[cache_key] = true

    -- retrieve timestamps
    local mod_mtime = get_mod_chunk_mtime(chunk_pos)
    local world_mtime = get_world_chunk_mtime(chunk_pos)

    if not mod_mtime then
        -- the chunk isn't available in the mod
        return
    end

    if world_mtime and world_mtime >= mod_mtime then
        -- world chunk is same or newer (?) than the one in the mod
        return
    end

    local mapblock_min, mapblock_max = import_mod.get_mapblock_bounds_from_chunk(chunk_pos)
    local min = import_mod.get_mapblock_bounds_from_mapblock(mapblock_min)
    local _, max = import_mod.get_mapblock_bounds_from_mapblock(mapblock_max)

    minetest.delete_area(min, max)
end

local function check_players()
    for _, player in ipairs(minetest.get_connected_players()) do
        check_player_pos(player)
    end
    minetest.after(1, check_players)
end

print("[modgen] map auto-update enabled")
minetest.after(1, check_players)
