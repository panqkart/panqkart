core_game = { }
core_game.position = { x = -95.6, y = 3.5, z = 198.5 } -- Default lobby position

minetest.register_privilege("core_admin", {
    description = "Can manage the lobby position and core game configurations.",
    give_to_singleplayer = true,
	give_to_admin = true,
})

local game_started = true
local is_end = false
local count = 0

local use_hovercraft = false
local use_car01 = false

function core_game.get_formspec(name)
    -- TODO: display whether the last guess was higher or lower
    local text = "Which car/vehicle do you want to use?"

    local formspec = {
        "formspec_version[4]",
        "size[7,3.75]",
        "label[0.5,0.5;", minetest.formspec_escape(text), "]",
        --"field[0.375,1.25;5.25,0.8;number;Number;]",
        "button[0.3,2.3;3,0.8;use_hovercraft;Hovercraft]",
		"button[3.8,2.3;3,0.8;use_car;Car01]"
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

minetest.register_chatcommand("change_position", {
	params = "<x y z>",
	description = "Change lobby's position",
    privs = {
        core_admin = true,
    },
    func = function(name, param)
		-- Start: code taken from Minetest builtin teleport command
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if not p.x and not p.y and not p.z then
			return false, "Wrong usage of command. Use <x y z>"
		end
		-- End: code taken from Minetest builtin teleport command
		core_game.position = {x = p.x, y = p.y, z = p.z}
		return true, "Changed lobby's position to: <" .. param .. ">"
    end,
})

minetest.register_on_joinplayer(function(player)
	player:set_pos(core_game.position)
	minetest.log("action", "[RACING GAME] Player " .. player:get_player_name() .. " joined and was teleported to the lobby successfully.")
	core_game.start_game(player)
end)

minetest.register_on_dieplayer(function(player)
	player:set_pos(core_game.position)
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_all(player:get_player_name() .. " just joined! Welcome to the Racing Game!")
end)

local function hud_321(player)
	local hud = player:hud_add({
		hud_elem_type = "image",
		position      = {x = 0.5, y = 0.5},
		offset        = {x = 0,   y = 0},
		text          = "core_game_3.png",
		alignment     = {x = 0, y = 0},
		scale         = {x = 1, y = 1},
   })
   minetest.after(3, function() player:hud_change(hud, "text", "core_game_2.png")
	   minetest.after(1, function() player:hud_change(hud, "text", "core_game_1.png") end) -- Change text to `1` AFTER the text is `2`
   end)
   minetest.after(5, function() player:hud_change(hud, "text", "core_game_go.png") end)
   minetest.after(7, function() player:hud_remove(hud) end)
   game_started = true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "core_game:choose_car" then
        return
    end

    if fields.use_hovercraft then
        local pname = player:get_player_name()
        minetest.chat_send_player(pname, "You will use Hovercraft in the next race.")

		use_hovercraft = true
	elseif fields.use_car then
		local pname = player:get_player_name()
        minetest.chat_send_player(pname, "You will use Car01 in the next race.")

		use_car01 = true
    end

	if use_car01 == true then
		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:car_dark_grey", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)
	elseif use_hovercraft == true then
		local obj = minetest.add_entity(player:get_pos(), "vehicle_mash:hover_blue", nil)
		lib_mount.attach(obj:get_luaentity(), player, false, 0)
	end
end)

function core_game.start_game(player)
	-- Ask the player which car they want to use
	local meta = player:get_meta()
	local data = minetest.deserialize(meta:get_string("hovercraft_bought"))

	if data and data.bought_already == true then
		minetest.show_formspec(player:get_player_name(), "core_game:choose_car", core_game.get_formspec(player))
	end


	-- Start: HUD stuff
	hud_321(player)
	-- End: HUD stuff

	-- Start: count stuff

	-- End: count stuff
end
