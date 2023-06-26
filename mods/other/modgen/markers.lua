
-- hud mappings
local pos1_player_map = {}
local pos2_player_map = {}

function modgen.get_pos(index, playername)
	if minetest.get_modpath("worldedit") then
		-- use WE's positions
		if index == 1 then
			return worldedit.pos1[playername]
		else
			return worldedit.pos2[playername]
		end
	end

	-- use local positions
	if index == 1 then
		return modgen.pos1[playername]
	else
		return modgen.pos2[playername]
	end
end

function modgen.set_pos(index, playername, pos)
	if minetest.get_modpath("worldedit") then
		-- worldedit available, use its markers
		if index == 1 then
			worldedit.pos1[playername] = pos
			worldedit.mark_pos1(playername);
		elseif index == 2 then
			worldedit.pos2[playername] = pos
			worldedit.mark_pos2(playername);
		end

		return
	end

	local map = modgen.pos1
	local hud_map = pos1_player_map
	if index == 2 then
		map = modgen.pos2
		hud_map = pos2_player_map
	end
	map[playername] = pos

	local player = minetest.get_player_by_name(playername)
	if player then
		-- set up hud elements
		local pos_str = minetest.pos_to_string(pos)
		minetest.chat_send_player(playername, "Position " .. index .. " set to " .. pos_str)

		if hud_map[playername] then
			player:hud_remove(hud_map[playername])
		end

		hud_map[playername] = player:hud_add({
			hud_elem_type = "waypoint",
			name = "Position " .. index .. " @ " .. pos_str,
			text = "m",
			number = 0xFF0000,
			world_pos = pos
		})
	end
end

-- cleanup
minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	pos1_player_map[playername] = nil
	pos2_player_map[playername] = nil
end)
