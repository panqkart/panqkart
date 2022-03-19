if minetest.get_modpath("default") then return end

local S = minetest.get_translator

minetest.register_node("default_nodes:stone", {
	description = "Stone",
	tiles = {"default_nodes_stone.png"},
	groups = {cracky = 3, stone = 1},
	drop = "default_nodes:cobble",
})

minetest.register_node("default_nodes:cobble", {
	description = "Cobblestone",
	tiles = {"default_nodes_cobble.png"},
	is_ground_content = false,
	--groups = {cracky = 3, stone = 2},
})

minetest.register_node("default_nodes:wood", {
	description = "Apple Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_wood.png"},
	is_ground_content = false,
	--groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	--sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("default_nodes:dirt", {
	description = "Dirt",
	tiles = {"default_nodes_dirt.png"},
	--groups = {crumbly = 3, soil = 1},
	--sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default_nodes:dirt_with_grass", {
	description = "Dirt with Grass",
	tiles = {"default_nodes_grass.png", "default_nodes_dirt.png",
		{name = "default_nodes_dirt.png^default_nodes_grass_side.png",
			tileable_vertical = false}},
	--groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = "default_nodes:dirt",
	--sounds = default.node_sound_dirt_defaults({
		--footstep = {name = "default_grass_footstep", gain = 0.25},
	--}),
})

minetest.register_node("default_nodes:mese", {
	description = "Mese Block",
	tiles = {"default_nodes_mese_block.png"},
	paramtype = "light",
	--groups = {cracky = 1, level = 2},
	--sounds = default.node_sound_stone_defaults(),
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
	--groups = {cracky = 2},
	--sounds = default.node_sound_metal_defaults(),
})

local bookshelf_formspec =
	"size[8,7;]" ..
	"list[context;books;0,0.3;8,2;]" ..
	"list[current_player;main;0,2.85;8,1;]" ..
	"list[current_player;main;0,4.08;8,3;8]" ..
	"listring[context;books]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0,2.85)

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
	--sounds = default.node_sound_wood_defaults(),

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
		default.get_inventory_drops(pos, "books", drops)
		drops[#drops+1] = "default_nodes:bookshelf"
		minetest.remove_node(pos)
		return drops
	end,
})

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
		title = data.title
		text = data.text
		owner = data.owner

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if data.page then
			page = data.page
			page_max = data.page_max

			for i = ((lpp * page) - lpp) + 1, lpp * page do
				if not lines[i] then break end
				string = string .. lines[i] .. "\n"
			end
		end
	end

	local formspec
	local esc = minetest.formspec_escape
	if owner == player_name then
		formspec = "size[8,8]" ..
			"field[0.5,1;7.5,0;title;" .. esc(S("Title:")) .. ";" ..
				esc(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;text;" .. esc(S("Contents:")) .. ";" ..
				esc(text) .. "]" ..
			"button_exit[2.5,7.5;3,1;save;" .. esc(S("Save")) .. "]"
	else
		formspec = "size[8,8]" ..
			"label[0.5,0.5;" .. esc(S("by @1", owner)) .. "]" ..
			"tablecolumns[color;text]" ..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
			"table[0.4,0;7,0.5;title;#FFFF00," .. esc(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;;" ..
				minetest.formspec_escape(string ~= "" and string or text) .. ";]" ..
			"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
			"label[3.2,7.7;" .. esc(S("Page @1 of @2", page, page_max)) .. "]" ..
			"button[4.9,7.6;0.8,0.8;book_next;>]"
	end

	minetest.show_formspec(player_name, "default_nodes:book", formspec)
	return itemstack
end

local max_text_size = 10000
local max_title_size = 80
local short_title_size = 35
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "default_nodes:book" then return end
	local inv = player:get_inventory()
	local stack = player:get_wielded_item()

	if fields.save and fields.title and fields.text
			and fields.title ~= "" and fields.text ~= "" then
		local new_stack, data
		if stack:get_name() ~= "default_nodes:book_written" then
			local count = stack:get_count()
			if count == 1 then
				stack:set_name("default_nodes:book_written")
			else
				stack:set_count(count - 1)
				new_stack = ItemStack("default_nodes:book_written")
			end
		else
			data = stack:get_meta():to_table().fields
		end

		if data and data.owner and data.owner ~= player:get_player_name() then
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
		local data = stack:get_meta():to_table().fields
		if not data or not data.page then
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
	--groups = {book = 1, flammable = 3},
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
