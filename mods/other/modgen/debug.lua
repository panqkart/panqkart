
local debug_enabled_players = {}
local hud_data = {}

minetest.register_chatcommand("modgen_debug", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "player not found"
		end

		if param == "on" then
			debug_enabled_players[name] = true
			return true, "Debug enabled"
		else
			debug_enabled_players[name] = false
			return true, "Debug disabled"
		end
	end
})

local function setup_hud(player, name)
	local data = {}
	hud_data[name] = data
	data.debug_txt = player:hud_add({
		hud_elem_type = "text",
		position = { x=0.5, y=0.5 },
		alignment = { x=1, y=0 },
		text = "Initializing..."
	})
end

local function remove_hud(player, name)
	local data = hud_data[name]
	if data then
		player:hud_remove(data.debug_txt)
	end
	hud_data[name] = nil
end

local function update_hud(player, data)
	local pos = player:get_pos()

	local mapblock_pos = modgen.get_mapblock(pos)
	local chunk_pos = modgen.get_chunkpos(pos)

	player:hud_change(data.debug_txt, "text", dump({
		chunk_pos = chunk_pos,
		mapblock_pos = mapblock_pos
	}))
end

local function debug_worker()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()

		if debug_enabled_players[name] and not hud_data[name] then
			setup_hud(player, name)
		elseif debug_enabled_players[name] and hud_data[name] then
			update_hud(player, hud_data[name])
		elseif not debug_enabled_players[name] and hud_data[name] then
			remove_hud(player, name)
		end
	end

	minetest.after(1, debug_worker)
end

minetest.register_on_leaveplayer(remove_hud)
minetest.after(1, debug_worker)