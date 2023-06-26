
-- player => { name => id }
local hud_data = {}

local hud_position = { x = 0.1, y = 0.9 }

local function setup_hud(player)
	local data = {}

	data.img = player:hud_add({
		hud_elem_type = "image",
		position = hud_position,
		text = "modgen_loaded.png",
		offset = {x = 0,   y = 0},
		alignment = { x = -1, y = 0},
		scale = {x = 2, y = 2}
	})

	data.text = player:hud_add({
		hud_elem_type = "text",
		position = hud_position,
		number = 0x00ff00,
		text = "",
		offset = {x = 0,   y = -8},
		alignment = { x = 1, y = 0},
		scale = {x = 2, y = 2}
	})

	data.text2 = player:hud_add({
		hud_elem_type = "text",
		position = hud_position,
		number = 0x00ff00,
		text = "",
		offset = {x = 0,   y = 8},
		alignment = { x = 1, y = 0},
		scale = {x = 2, y = 2}
	})

	hud_data[player:get_player_name()] = data
end

local function update_player_hud(player)

	local playername = player:get_player_name()
	local data = hud_data[playername]
	if not data then
		return
	end

	local txt = "Modgen: "

	if modgen.autosave then
		txt = txt .. "autosave enabled"
		player:hud_change(data.img, "text", "modgen_autosave.png")
	else
		txt = txt .. "saving"
		player:hud_change(data.img, "text", "modgen_loaded.png")
	end

	txt = txt .. " @ '" .. modgen.export_path .. "'"
	local txt2 = "size: " .. modgen.pretty_size(modgen.manifest.size) ..
		", chunks: " .. modgen.manifest.chunks ..
		", unique nodes: " .. modgen.manifest.next_id

	player:hud_change(data.text, "text", txt)
	player:hud_change(data.text2, "text", txt2)
end

-- init

local function update_hud()
	for _, player in ipairs(minetest.get_connected_players()) do
		update_player_hud(player)
	end
	minetest.after(1, update_hud)
end
minetest.after(1, update_hud)

minetest.register_on_joinplayer(function(player)
	if minetest.check_player_privs(player, { server = true }) then
		setup_hud(player)
		update_player_hud(player)
	end
end)
