if minetest.get_modpath("default") then return end

default_nodes = {}

local S = minetest.get_translator

default_nodes.gui_bg     = ""
default.gui_slots  = ""

-- Start: taken from the `default` mod
function default_nodes.get_hotbar_bg(x,y)
	local out = ""
	for i=0,7,1 do
		out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
	end
	return out
end

function default_nodes.get_inventory_drops(pos, inventory, drops)
	local inv = minetest.get_meta(pos):get_inventory()
	local n = #drops
	for i = 1, inv:get_size(inventory) do
		local stack = inv:get_stack(inventory, i)
		if stack:get_count() > 0 then
			drops[n+1] = stack:to_table()
			n = n + 1
		end
	end
end

function default_nodes.can_interact_with_node(player, pos)
	if player and player:is_player() then
		if minetest.check_player_privs(player, "protection_bypass") then
			return true
		end
	else
		return false
	end

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if not owner or owner == "" or owner == player:get_player_name() then
		return true
	end

	-- Is player wielding the right key?
	local item = player:get_wielded_item()
	if minetest.get_item_group(item:get_name(), "key") == 1 then
		local key_meta = item:get_meta()

		if key_meta:get_string("secret") == "" then
			local key_oldmeta = item:get_metadata()
			if key_oldmeta == "" or not minetest.parse_json(key_oldmeta) then
				return false
			end

			key_meta:set_string("secret", minetest.parse_json(key_oldmeta).secret)
			item:set_metadata("")
		end

		return meta:get_string("key_lock_secret") == key_meta:get_string("secret")
	end

	return false
end

function default_nodes.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "", gain = 1.0}
	table.dug = table.dug or
			{name = "default_nodes_dug_node", gain = 0.25}
	table.place = table.place or
			{name = "default_nodes_place_node_hard", gain = 1.0}
	return table
end

function default_nodes.node_sound_stone_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_hard_footstep", gain = 0.2}
	table.dug = table.dug or
			{name = "default_nodes_hard_footstep", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_dirt_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_dirt_footstep", gain = 0.25}
	table.dig = table.dig or
			{name = "default_nodes_dig_crumbly", gain = 0.4}
	table.dug = table.dug or
			{name = "default_nodes_dirt_footstep", gain = 1.0}
	table.place = table.place or
			{name = "default_nodes_place_node", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_sand_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_sand_footstep", gain = 0.05}
	table.dug = table.dug or
			{name = "default_nodes_sand_footstep", gain = 0.15}
	table.place = table.place or
			{name = "default_nodes_place_node", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_gravel_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_gravel_footstep", gain = 0.25}
	table.dig = table.dig or
			{name = "default_nodes_gravel_dig", gain = 0.35}
	table.dug = table.dug or
			{name = "default_nodes_gravel_dug", gain = 1.0}
	table.place = table.place or
			{name = "default_nodes_place_node", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_wood_footstep", gain = 0.15}
	table.dig = table.dig or
			{name = "default_nodes_dig_choppy", gain = 0.4}
	table.dug = table.dug or
			{name = "default_nodes_wood_footstep", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_grass_footstep", gain = 0.45}
	table.dug = table.dug or
			{name = "default_nodes_grass_footstep", gain = 0.7}
	table.place = table.place or
			{name = "default_nodes_place_node", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_glass_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_glass_footstep", gain = 0.3}
	table.dig = table.dig or
			{name = "default_nodes_glass_footstep", gain = 0.5}
	table.dug = table.dug or
			{name = "default_nodes_break_glass", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_ice_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_ice_footstep", gain = 0.15}
	table.dig = table.dig or
			{name = "default_nodes_ice_dig", gain = 0.5}
	table.dug = table.dug or
			{name = "default_nodes_ice_dug", gain = 0.5}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_metal_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_metal_footstep", gain = 0.2}
	table.dig = table.dig or
			{name = "default_nodes_dig_metal", gain = 0.5}
	table.dug = table.dug or
			{name = "default_nodes_dug_metal", gain = 0.5}
	table.place = table.place or
			{name = "default_nodes_place_node_metal", gain = 0.5}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_water_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_water_footstep", gain = 0.2}
	default_nodes.node_sound_defaults(table)
	return table
end

function default_nodes.node_sound_snow_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_nodes_snow_footstep", gain = 0.2}
	table.dig = table.dig or
			{name = "default_nodes_snow_footstep", gain = 0.3}
	table.dug = table.dug or
			{name = "default_nodes_snow_footstep", gain = 0.3}
	table.place = table.place or
			{name = "default_nodes_place_node", gain = 1.0}
	default_nodes.node_sound_defaults(table)
	return table
end
-- End: taken code from the `default` mod

------------
-- Nodes --
------------

minetest.register_node("default_nodes:junglewood", {
	description = "Jungle Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_junglewood.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default_nodes.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:pine_wood", {
	description = "Pine Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_pine_wood.png"},
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3, wood = 1},
	sounds = default_nodes.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:aspen_wood", {
	description = "Aspen Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_aspen_wood.png"},
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3, wood = 1},
	sounds = default_nodes.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:acacia_wood", {
	description = "Acacia Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_acacia_wood.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default_nodes.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:stone", {
	description = "Stone",
	tiles = {"default_nodes_stone.png"},
	groups = {cracky = 3, stone = 1},
	drop = "default_nodes:cobble",
	sounds = default_nodes.node_sound_stone_defaults(),
})

minetest.register_node("default_nodes:cobble", {
	description = "Cobblestone",
	tiles = {"default_nodes_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default_nodes.node_sound_stone_defaults(),
})

minetest.register_node("default_nodes:tree", {
	description = "Apple Tree",
	tiles = {"default_nodes_tree_top.png", "default_nodes_tree_top.png", "default_nodes_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default_nodes.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node("default_nodes:wood", {
	description = "Apple Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_wood.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default_nodes.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:leaves", {
	description = "Apple Tree Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	tiles = {"default_nodes_leaves.png"},
	special_tiles = {"default_nodes_leaves_simple.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {"default_nodes:leaves"},
			}
		}
	},
	sounds = default_nodes.node_sound_leaves_defaults(),

	after_place_node = after_place_leaves,
})

minetest.register_node("default_nodes:dirt", {
	description = "Dirt",
	tiles = {"default_nodes_dirt.png"},
	groups = {crumbly = 3, soil = 1},
	sounds = default_nodes.node_sound_dirt_defaults(),
})

minetest.register_node("default_nodes:dirt_with_grass", {
	description = "Dirt with Grass",
	tiles = {"default_nodes_grass.png", "default_nodes_dirt.png",
		{name = "default_nodes_dirt.png^default_nodes_grass_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = "default_nodes:dirt",
	sounds = default_nodes.node_sound_dirt_defaults({
		footstep = {name = "default_nodes_grass_footstep", gain = 0.25},
	}),
})

minetest.register_node("default_nodes:mese", {
	description = "Mese Block",
	tiles = {"default_nodes_mese_block.png"},
	paramtype = "light",
	groups = {cracky = 1, level = 2},
	sounds = default_nodes.node_sound_stone_defaults(),
	light_source = 3,
})

minetest.register_node("default_nodes:ladder_steel", {
	description = "Steel Ladder",
	drawtype = "signlike",
	tiles = {"default_nodes_ladder_steel.png"},
	inventory_image = "default_nodes_ladder_steel.png",
	wield_image = "default_nodes_ladder_steel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {cracky = 2},
	sounds = default_nodes.node_sound_metal_defaults(),
})

minetest.register_node("default_nodes:steelblock", {
	description = "Steel Block",
	tiles = {"default_nodes_steel_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default_nodes.node_sound_metal_defaults(),
})

local bookshelf_formspec =
	"size[8,7;]" ..
	"list[context;books;0,0.3;8,2;]" ..
	"list[current_player;main;0,2.85;8,1;]" ..
	"list[current_player;main;0,4.08;8,3;8]" ..
	"listring[context;books]" ..
	"listring[current_player;main]" ..
	default_nodes.get_hotbar_bg(0,2.85)

local function update_bookshelf(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local invlist = inv:get_list("books")

	local formspec = bookshelf_formspec
	-- Inventory slots overlay
	local bx, by = 0, 0.3
	local n_written, n_empty = 0, 0
	for i = 1, 16 do
		if i == 9 then
			bx = 0
			by = by + 1
		end
		local stack = invlist[i]
		if stack:is_empty() then
			formspec = formspec ..
				"image[" .. bx .. "," .. by .. ";1,1;default_nodes_bookshelf_slot.png]"
		else
			local metatable = stack:get_meta():to_table() or {}
			if metatable.fields and metatable.fields.text then
				n_written = n_written + stack:get_count()
			else
				n_empty = n_empty + stack:get_count()
			end
		end
		bx = bx + 1
	end
	meta:set_string("formspec", formspec)
	if n_written + n_empty == 0 then
		meta:set_string("infotext", S("Empty Bookshelf"))
	else
		meta:set_string("infotext", S("Bookshelf (@1 written, @2 empty books)", n_written, n_empty))
	end
end

minetest.register_node("default_nodes:bookshelf", {
	description = "Bookshelf",
	tiles = {"default_nodes_wood.png", "default_nodes_wood.png", "default_nodes_wood.png",
		"default_nodes_wood.png", "default_nodes_bookshelf.png", "default_nodes_bookshelf.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	--groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default_nodes.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("books", 8 * 2)
		update_bookshelf(pos)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("books")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
			return stack:get_count()
		end
		return 0
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" puts stuff to bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_blast = function(pos)
		local drops = {}
		default_nodes.get_inventory_drops(pos, "books", drops)
		drops[#drops+1] = "default_nodes:bookshelf"
		minetest.remove_node(pos)
		return drops
	end,
})

local esc = minetest.formspec_escape
local formspec_size = "size[8,8]"

local function formspec_core(tab)
	if tab == nil then tab = 1 else tab = tostring(tab) end
	return "tabheader[0,0;book_header;" ..
		esc("Write") .. "," ..
		esc("Read") .. ";" ..
		tab  ..  ";false;false]"
end

local function formspec_write(title, text)
	return "field[0.5,1;7.5,0;title;" .. esc("Title:") .. ";" ..
			esc(title) .. "]" ..
		"textarea[0.5,1.5;7.5,7;text;" .. esc("Contents:") .. ";" ..
			esc(text) .. "]" ..
		"button_exit[2.5,7.5;3,1;save;" .. esc("Save") .. "]"
end

local function formspec_read(owner, title, string, text, page, page_max)
	return "label[0.5,0.5;" .. esc("by " .. owner) .. "]" ..
		"tablecolumns[color;text]" ..
		"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
		"table[0.4,0;7,0.5;title;#FFFF00," .. esc(title) .. "]" ..
		"textarea[0.5,1.5;7.5,7;;" ..
			esc(string ~= "" and string or text) .. ";]" ..
		"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
		"label[3.2,7.7;" .. esc("Page " .. page ..  " of " .. page_max) .. "]" ..
		"button[4.9,7.6;0.8,0.8;book_next;>]"
end

local function formspec_string(lpp, page, lines, string)
	for i = ((lpp * page) - lpp) + 1, lpp * page do
		if not lines[i] then break end
		string = string .. lines[i] .. "\n"
	end
	return string
end

local tab_number
local lpp = 14 -- Lines per book's page
local function book_on_use(itemstack, user)
	local player_name = user:get_player_name()
	local meta = itemstack:get_meta()
	local title, text, owner = "", "", player_name
	local page, page_max, lines, string = 1, 1, {}, ""

	-- Backwards compatibility
	local old_data = minetest.deserialize(itemstack:get_metadata())
	if old_data then
		meta:from_table({ fields = old_data })
	end

	local data = meta:to_table().fields

	if data.owner then
		title = data.title or ""
		text = data.text or ""
		owner = data.owner

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if data.page then
			page = data.page
			page_max = data.page_max
			string = formspec_string(lpp, page, lines, string)
		end
	end

	local formspec
	if title == "" and text == "" then
		formspec = formspec_write(title, text)
	elseif owner == player_name then
		local tab = tab_number or 1
		if tab == 2 then
			formspec = formspec_core(tab) ..
				formspec_read(owner, title, string, text, page, page_max)
		else
			formspec = formspec_core(tab) .. formspec_write(title, text)
		end
	else
		formspec = formspec_read(owner, title, string, text, page, page_max)
	end

	minetest.show_formspec(player_name, "default_nodes:book", formspec_size .. formspec)
	return itemstack
end

local max_text_size = 10000
local max_title_size = 80
local short_title_size = 35
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "default_nodes:book" then return end
	local player_name = player:get_player_name()
	local inv = player:get_inventory()
	local stack = player:get_wielded_item()
	local data = stack:get_meta():to_table().fields

	local title = data.title or ""
	local text = data.text or ""

	if fields.book_header ~= nil and data.owner == player_name then
		local contents
		local tab = tonumber(fields.book_header)
		if tab == 1 then
			contents = formspec_core(tab) ..
				formspec_write(title, text)
		elseif tab == 2 then
			local lines, string = {}, ""
			for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
				lines[#lines+1] = str
			end
			string = formspec_string(lpp, data.page, lines, string)
			contents = formspec_read(player_name, title, string,
				text, data.page, data.page_max)
		end
		tab_number = tab
		local formspec = formspec_size .. formspec_core(tab) .. contents
		minetest.show_formspec(player_name, "default_nodes:book", formspec)
		return
	end

	if fields.save and fields.title and fields.text then
		local new_stack
		if stack:get_name() ~= "default_nodes:book_written" then
			local count = stack:get_count()
			if count == 1 then
				stack:set_name("default_nodes:book_written")
			else
				stack:set_count(count - 1)
				new_stack = ItemStack("default_nodes:book_written")
			end
		end

		if data.owner ~= player_name and title ~= "" and text ~= "" then
			return
		end

		if not data then data = {} end
		data.title = fields.title:sub(1, max_title_size)
		data.owner = player:get_player_name()
		local short_title = data.title
		-- Don't bother triming the title if the trailing dots would make it longer
		if #short_title > short_title_size + 3 then
			short_title = short_title:sub(1, short_title_size) .. "..."
		end
		data.description = S("\"@1\" by @2", short_title, data.owner)
		data.text = fields.text:sub(1, max_text_size)
		data.text = data.text:gsub("\r\n", "\n"):gsub("\r", "\n")
		data.page = 1
		data.page_max = math.ceil((#data.text:gsub("[^\n]", "") + 1) / lpp)

		if new_stack then
			new_stack:get_meta():from_table({ fields = data })
			if inv:room_for_item("main", new_stack) then
				inv:add_item("main", new_stack)
			else
				minetest.add_item(player:get_pos(), new_stack)
			end
		else
			stack:get_meta():from_table({ fields = data })
		end

	elseif fields.book_next or fields.book_prev then
		if not data.page then
			return
		end

		data.page = tonumber(data.page)
		data.page_max = tonumber(data.page_max)

		if fields.book_next then
			data.page = data.page + 1
			if data.page > data.page_max then
				data.page = 1
			end
		else
			data.page = data.page - 1
			if data.page == 0 then
				data.page = data.page_max
			end
		end

		stack:get_meta():from_table({fields = data})
		stack = book_on_use(stack, player)
	end

	-- Update stack
	player:set_wielded_item(stack)
end)

minetest.register_craftitem("default_nodes:book", {
	description = "Book",
	inventory_image = "default_nodes_book.png",
	groups = {book = 1},
	on_use = book_on_use,
})

minetest.register_craftitem("default_nodes:book_written", {
	description = S("Book with Text"),
	inventory_image = "default_nodes_book_written.png",
	groups = {book = 1, not_in_creative_inventory = 1, flammable = 3},
	stack_max = 1,
	on_use = book_on_use,
})

minetest.register_node("default_nodes:lava_source", {
	description = "Lava Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_nodes_lava_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
		{
			name = "default_nodes_lava_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	paramtype = "light",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default_nodes:lava_flowing",
	liquid_alternative_source = "default_nodes:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	damage_per_second = 4 * 2,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	--groups = {lava = 3, liquid = 2, igniter = 1},
})

minetest.register_node("default_nodes:lava_flowing", {
	description = "Flowing Lava",
	drawtype = "flowingliquid",
	tiles = {"default_lava.png"},
	special_tiles = {
		{
			name = "default_nodes_lava_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
		{
			name = "default_nodes_lava_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default_nodes:lava_flowing",
	liquid_alternative_source = "default_nodes:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	damage_per_second = 4 * 2,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	--groups = {lava = 3, liquid = 2, igniter = 1,
		--not_in_creative_inventory = 1},
	groups = {not_in_creative_inventory = 1},
})

--[[
minetest.register_node("default_nodes:water_source", {
	description = S("Water Source"),
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_nodes_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "default_nodes_water_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default_nodes:water_flowing",
	liquid_alternative_source = "default_nodes:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	sounds = default_nodes.node_sound_water_defaults(),
})

minetest.register_node("default_nodes:water_flowing", {
	description = S("Flowing Water"),
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"default_nodes_water.png"},
	special_tiles = {
		{
			name = "default_nodes_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "default_nodes_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default_nodes:water_flowing",
	liquid_alternative_source = "default_nodes:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1,
		cools_lava = 1},
	sounds = default_nodes.node_sound_water_defaults(),
})
--]]
