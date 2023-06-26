--[[
	## StreetsMod 2.0 ##
	Submod: workshop
	Optional: false
]]

streets.dyes = {
	{ color = "white",  name = "White",  hex = "#ffffff" },
	{ color = "yellow", name = "Yellow", hex = "#ffff00" },
	{ color = "orange", name = "Orange", hex = "#ff7f00" },
	{ color = "red",    name = "Red",    hex = "#ff0000" },
	{ color = "green",  name = "Green",  hex = "#00ff00" },
	{ color = "blue",   name = "Blue",   hex = "#0000ff" },
	{ color = "brown",  name = "Brown",  hex = "#854c30" },
	{ color = "grey",   name = "Grey",   hex = "#808080" },
	{ color = "black",  name = "Black",  hex = "#000000" },
}


local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("progress", 0)
	meta:set_string("working_on", "")
	meta:set_string("selection", "")
	meta:set_int("maxpage", 1)
	meta:set_int("page", 1)
	meta:set_int("maxpage", 1)
	meta:set_string("section", "")
	meta:set_string("category", "")
	meta:set_int("tab", 1)
	meta:set_int("locked", 1)
	meta:set_int("creative_enabled", 1)
	meta:set_int("clear_selection", 1)
	meta:set_string("color", "white")
	meta:set_string("rotation", "r0")
	for _, dye in ipairs(streets.dyes) do
		meta:set_float(dye.color .. "_storage", 0)
	end
end

local update_formspec = function(pos)
	local meta = minetest.get_meta(pos)
	local tab = meta:get_int("tab")
	local section = meta:get_string("section")
	local selection = meta:get_string("selection")
	local category = meta:get_string("category")
	local page = meta:get_int("page")
	local rotation = meta:get_string("rotation")
	local color = meta:get_string("color")
	local maxpage = meta:get_int("maxpage") -- luacheck: no unused
	local locked = meta:get_int("locked")
	local creative_enabled = meta:get_int("creative_enabled")
	local clear_selection = meta:get_int("clear_selection")

	local fs = "size[9,9;]"
	fs = fs .. default.gui_bg .. default.gui_bg_img .. default.gui_slots
	fs = fs .. "tabheader[0,0;tabs;Tutorial,Dye Storage,Select Section: Signs,Select Section: Asphalt,Craft,Setup"
	fs = fs .. ";" .. tab .. ";true;false]"
	if tab == 1 then -- Tutorial
		fs = fs .. "label[0,0;"
		fs = fs .. "Welcome to the Tutorial! The Streets Workshop is a new method of crafting.\n"
		fs = fs .. "You can craft traffic signs, roadmarkings and colored asphalt in this workshop.\n"
		fs = fs .. "First of all, you have to select a section.\n"
		fs = fs .. "For this, you either have to click on \"Select Section: Signs\" or \"Select Section: Asphalt\".\n"
		fs = fs .. "There, you have further options: \n"
		fs = fs .. "You can select what kind of sign respectively roadmarking you want to produce.\n"
		fs = fs .. "In the \"Craft\" tab, you will be able to select an item to craft.\n"
		fs = fs .. "Then you have to provide a base material:\n"
		fs = fs .. "Steel ingots for roadmarkings, steel signs for traffic signs and black asphalt for coloring asphalt.\n"
		fs = fs .. "Additionlly, you will need dye. Which dye you will need is stated in the craft tab.\n"
		fs = fs .. "For using dye in the workshop, you have to fill the \"Dye Storage\":\n"
		fs = fs .. "Put the dyes in the slots at the top (according to the color).\n"
		fs = fs .. "]"
	elseif tab == 2 then -- Dye Storage
		local x = 0
		for _, dye in ipairs(streets.dyes) do
			fs = fs .. "list[context;" .. dye.color .. "_dye;" .. x .. ",0;1,1]"
			fs = fs .. "image[" .. x .. ",0;1,1;dye_grey.png^[multiply:#333333^[colorize:#ffffff:100]"
			fs = fs .. "box[" .. x .. ",1;0.8,2;#141318]"
			local height = math.max(0.05, meta:get_float(dye.color .. "_storage") * 2)
			fs = fs .. "box[" .. x .. "," .. 3 - height .. ";0.8," .. height .. ";" .. dye.hex .. "]"
			fs = fs .. "item_image[" .. x .. ",3;1,1;dye:" .. dye.color .. "]"
			x = x + 1
		end
	elseif tab == 3 then -- Select Section: Signs
		local x_pos = 0.5
		local y_pos = 0
		for k, v in pairs(streets.signs.sections) do
			fs = fs .. "button[" .. x_pos .. "," .. y_pos .. ";2.5,1;"
			fs = fs .. minetest.formspec_escape(v.name) .. ";"
			fs = fs .. minetest.formspec_escape(v.friendlyname) .. "]"
			y_pos = y_pos + 0.8
			if y_pos > 4 then
				y_pos = 0
				x_pos = x_pos + 2.5
			end
		end
	elseif tab == 4 then -- Select Section: Asphalt
		local x_pos = 0.5
		local y_pos = 0
		for k, v in pairs(streets.labels.sections) do
			fs = fs .. "button[" .. x_pos .. "," .. y_pos .. ";3.5,1;"
			fs = fs .. minetest.formspec_escape(v.name) .. ";"
			fs = fs .. minetest.formspec_escape(v.friendlyname) .. "]"
			y_pos = y_pos + 0.8
			if y_pos > 4 then
				y_pos = 0
				x_pos = x_pos + 3.5
			end
		end
		fs = fs .."button[4,4;3.5,1;color_asphalt;Color Asphalt]"
	elseif tab == 5 then -- Craft
		if category == "signs" then
			local x = 0
			local y = 0
			local count = 0
			local items = {}
			for k, v in pairs(streets.signs.signtypes) do
				if v.section == section then
					local item = "streets:" .. v.name
					count = count + 1
					table.insert(items, item)
				end
			end
			maxpage = math.ceil(count / 12)
			if page < 1 then
				page = maxpage
			elseif page > maxpage then
				page = 1
			end
			meta:set_int("maxpage", maxpage)
			meta:set_int("page", page)
			for k, v in ipairs(items) do
				if k > (page - 1) * 12 and k <= page * 12 then
					fs = fs .. "item_image_button[" .. x + 0.5 .. "," .. y .. ";1,1;" .. v .. ";" .. v .. ";]"
					x = x + 1
					if x >= 3 then
						x = 0
						y = y + 1
					end
				end
			end
			if maxpage > 1 then
				fs = fs .. "button[3.75,2.25;1,1;prevpage;<-]"
				fs = fs .. "button[3.75,3.25;1,1;nextpage;->]"
				fs = fs .. "label[3.75,4;" .. string.format("Page %s of %s", page, maxpage) .. "]"
			end
			fs = fs .. "button[3.75,1;1,1;noselection;X]"
			fs = fs .. "tooltip[noselection;Remove Current Selection]"
			if streets.signs.signtypes[selection] then
				local sign = streets.signs.signtypes[selection]
				fs = fs .. "label[4.9,1.7;Needed dye:]"
				local y_pos = 2.2
				for _, dye in ipairs(streets.dyes) do
					if sign.dye_needed[dye.color] then
						fs = fs .. "label[4.9," .. y_pos .. ";"
						fs = fs .. minetest.colorize(dye.hex, dye.name .. ": " ..sign.dye_needed[dye.color] * 5 .. "%") .. "]"
						y_pos = y_pos + 0.4
					end
				end
			end

			fs = fs .. "label[6.9,2.3;Steel]"
			fs = fs .. "label[6.9,2.5;Sign]"
			fs = fs .. "image[6.9,3;1,1;default_sign_steel.png^[makealpha:170,170,170^[makealpha:181,181,181"
			fs = fs .. "^[makealpha:192,192,192^[makealpha:196,196,196^[multiply:#333333^[colorize:#ffffff:100]"
			fs = fs .. "list[context;sign_input;6.9,3;1,1]"
			fs = fs .. "label[8,0.2;Current]"
			fs = fs .. "label[8,0.5;Selection]"
			fs = fs .. "item_image[8,1;1,1;" .. selection .. "]"
			fs = fs .. "image[8,2;1,1;gui_furnace_arrow_bg.png^[lowpart:" .. meta:get_int("progress") * 10 .. ":gui_furnace_arrow_fg.png^[transformR180]"
			fs = fs .. "list[context;output;8,3;1,1]"
			fs = fs .. "label[4.9,0;Trash]"
			fs = fs .. "list[context;trash;4.9,0.4;1,1]"
			if creative then
				fs = fs .. "image[4.96,0.5;0.8,0.8;creative_trash_icon.png]"
			end
		elseif category == "labels" then
			fs = fs .. "label[0,0;Select]"
			fs = fs .. "label[0,0.3;Color]"
			fs = fs .. "image_button[0,0.8;1,1;dye_white.png;color_white;]"
			fs = fs .. "image_button[0,1.8;1,1;dye_yellow.png;color_yellow;]"
			fs = fs .. "label[1.25,0;Rotation]"
			fs = fs .. "button[1.25,0.5;1,1;r0;0°]"
			fs = fs .. "button[1.25,1.5;1,1;r90;90°]"
			fs = fs .. "button[1.25,2.5;1,1;r180;180°]"
			fs = fs .. "button[1.25,3.5;1,1;r270;270°]"
			local x = 0
			local y = 0
			local count = 0
			local items = {}
			for k, v in pairs(streets.labels.labeltypes) do
				if v.section == section then
					local item = ""
					if not streets.only_basic_stairsplus and v.rotation then
						if v.rotation.r90 and rotation == "r90" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r90"
						elseif v.rotation.r180 and rotation == "r180" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r180"
						elseif v.rotation.r270 and rotation == "r270" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r270"
						end
					elseif streets.only_basic_stairsplus and v.basic_rotation then
						if v.basic_rotation.r90 and rotation == "r90" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r90"
						elseif v.basic_rotation.r180 and rotation == "r180" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r180"
						elseif v.basic_rotation.r270 and rotation == "r270" then
							item = "streets:tool_" .. v.name:gsub("{color}", color:lower()) .. "_r270"
						end
					end
					if rotation == "r0" then
						item = "streets:tool_" .. v.name:gsub("{color}", color:lower())
					end
					if item ~= "" then
						count = count + 1
						table.insert(items, item)
					end
				end
			end
			maxpage = math.ceil(count / 12)
			if page < 1 then
				page = maxpage
			elseif page > maxpage then
				page = 1
			end
			meta:set_int("maxpage", maxpage)
			meta:set_int("page", page)
			for k, v in ipairs(items) do
				if k > (page - 1) * 12 and k <= page * 12 then
					fs = fs .. "item_image_button[" .. x + 2.5 .. "," .. y .. ";1,1;" .. v .. ";" .. v .. ";]"
					x = x + 1
					if x >= 3 then
						x = 0
						y = y + 1
					end
				end
			end
			if maxpage > 1 then
				fs = fs .. "button[5.75,2.25;1,1;prevpage;<-]"
				fs = fs .. "button[5.75,3.25;1,1;nextpage;->]"
				fs = fs .. "label[5.75,4;" .. string.format("Page %s of %s", page, maxpage) .. "]"
			end
			fs = fs .. "button[5.75,1;1,1;noselection;X]"
			fs = fs .. "tooltip[noselection;Remove Current Selection]"
			if selection:sub(1,13) == "streets:tool_" then
				local sel = selection:sub(14)
				local markingcolor
				if sel:find("white") then
					markingcolor = "White"
				elseif sel:find("yellow") then
					markingcolor = "Yellow"
				end
				sel = sel:gsub("white", "{color}")
				sel = sel:gsub("yellow", "{color}")
				sel = sel:gsub("_r90", "")
				sel = sel:gsub("_r180", "")
				sel = sel:gsub("_r270", "")
				local dye_needed = streets.labels.labeltypes[sel].dye_needed * 5
				fs = fs .. "label[6.9,0.7;" .. markingcolor .. "]"
				fs = fs .. "label[6.9,1;dye]"
				fs = fs .. "label[6.9,1.3;needed:]"
				fs = fs .. "label[6.9,1.6;" .. dye_needed .. "%]"
			end
			fs = fs .. "label[6.9,2.3;Steel]"
			fs = fs .. "label[6.9,2.5;Ingot]"
			fs = fs .. "image[6.9,3;1,1;default_steel_ingot.png^[multiply:#333333^[colorize:#ffffff:100]"
			fs = fs .. "list[context;steel_input;6.9,3;1,1]"
			fs = fs .. "label[8,0.2;Current]"
			fs = fs .. "label[8,0.5;Selection]"
			fs = fs .. "item_image[8,1;1,1;" .. selection .. "]"
			fs = fs .. "image[8,2;1,1;gui_furnace_arrow_bg.png^[lowpart:" .. meta:get_int("progress") * 10 .. ":gui_furnace_arrow_fg.png^[transformR180]"
			fs = fs .. "list[context;output;8,3;1,1]"
			fs = fs .. "label[0,3.1;Trash]"
			fs = fs .. "list[context;trash;0,3.5;1,1]"
			if creative then
				fs = fs .. "image[0.06,3.6;0.8,0.8;creative_trash_icon.png]"
			end
		elseif category == "asphalt" then
			fs = fs .. "label[0.5,0.65;Red Asphalt]"
			fs = fs .. "label[0.5,1.65;Blue Asphalt]"
			fs = fs .. "label[0.5,2.65;Sidewalk]"
			fs = fs .. "item_image_button[2.5,0.5;1,1;streets:asphalt_red;streets:asphalt_red;]"
			fs = fs .. "item_image_button[2.5,1.5;1,1;streets:asphalt_blue;streets:asphalt_blue;]"
			fs = fs .. "item_image_button[2.5,2.5;1,1;streets:sidewalk;streets:sidewalk;]"
			fs = fs .. "button[5,1;1,1;noselection;X]"
			fs = fs .. "tooltip[noselection;Remove Current Selection]"
			local asphalt_color = ""
			local asphalt_dye
			if selection == "streets:asphalt_red" then
				asphalt_color = "red"
			elseif selection == "streets:asphalt_blue" then
				asphalt_color = "blue"
			elseif selection == "streets:sidewalk" then
				asphalt_color = "white"
			end
			if selection == "streets:asphalt_red" or selection == "streets:asphalt_blue" or selection == "streets:sidewalk" then
				for _, dye in ipairs(streets.dyes) do
					if dye.color == asphalt_color then
						asphalt_dye = dye
					end
				end
				fs = fs .. "label[5,0;Needed dye:]"
				fs = fs .. "label[5,0.3;"
				fs = fs .. minetest.colorize(asphalt_dye.hex, asphalt_dye.name .. ": 5%") .. "]"
			end
			fs = fs .. "label[6.4,2.3;Black]"
			fs = fs .. "label[6.4,2.5;Asphalt]"
			fs = fs .. "list[context;asphalt_input;6.4,3;1,1]"
			fs = fs .. "label[7.5,0.2;Current]"
			fs = fs .. "label[7.5,0.5;Selection]"
			fs = fs .. "item_image[7.5,1;1,1;" .. selection .. "]"
			fs = fs .. "image[7.5,2;1,1;gui_furnace_arrow_bg.png^[lowpart:" .. meta:get_int("progress") * 10 .. ":gui_furnace_arrow_fg.png^[transformR180]"
			fs = fs .. "list[context;output;7.5,3;1,1]"
			fs = fs .. "label[3.75,0;Trash]"
			fs = fs .. "list[context;trash;3.75,0.4;1,1]"
			if creative then
				fs = fs .. "image[3.81,0.5;0.8,0.8;creative_trash_icon.png]"
			end
		end
	elseif tab == 6 then -- Setup
		fs = fs .. "label[0.5,0.65;Locked]"
		if locked == 1 then
			fs = fs .. "button[1.5,0.5;1,1;unlock;" .. minetest.colorize("#008800", "ON") .. "]"
		else
			fs = fs .. "button[1.5,0.5;1,1;lock;" .. minetest.colorize("#dd0000", "OFF") .. "]"
		end
		fs = fs .. "label[0.5,1.65;Creative]"
		if creative_enabled == 1 then
			fs = fs .. "button[1.5,1.5;1,1;turn_creative_off;" .. minetest.colorize("#008800", "ON") .. "]"
		else
			fs = fs .. "button[1.5,1.5;1,1;turn_creative_on;" .. minetest.colorize("#dd0000", "OFF") .. "]"
		end
		fs = fs .. "label[0.5,2.65;Clear selection on section change]"
		if clear_selection == 1 then
			fs = fs .. "button[3.5,2.5;1,1;turn_clear_off;" .. minetest.colorize("#008800", "ON") .. "]"
		else
			fs = fs .. "button[3.5,2.5;1,1;turn_clear_on;" .. minetest.colorize("#dd0000", "OFF") .. "]"
		end
	end
	fs = fs .. "list[current_player;main;0.5,5;8,4]"
	meta:set_string("formspec", fs)
end

local update_inventory = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("steel_input", 1)
	inv:set_size("sign_input", 1)
	inv:set_size("asphalt_input", 1)
	inv:set_size("trash", 1)
	local storage_per_dye = 0.25
	for _, dye in ipairs(streets.dyes) do
		inv:set_size(dye.color .. "_dye", 1)
		while inv:get_stack(dye.color .. "_dye", 1):get_count() > 0
				and inv:get_stack(dye.color .. "_dye", 1):get_name() == "dye:" .. dye.color
				and meta:get_float(dye.color .. "_storage") <= (1 - storage_per_dye) do
			meta:set_float(dye.color .. "_storage", meta:get_float(dye.color .. "_storage") + storage_per_dye)
			inv:remove_item(dye.color .. "_dye", { name = "dye:" .. dye.color, count = 1 })
		end
	end
	update_formspec(pos)
end

local on_receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local name = sender:get_player_name()
	if meta:get_int("locked") == 1 and minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
		minetest.record_protection_violation(pos, name)
		return
	end
	local creative_enabled = meta:get_int("creative_enabled") == 1 and creative and creative.is_enabled_for(name)
	local clear_selection = meta:get_int("clear_selection") == 1
	local inv = minetest.get_inventory({type="player", name=name})
	if fields.tabs then
		meta:set_int("tab", fields.tabs)
	elseif fields.color_white then
		meta:set_string("color", "white")
	elseif fields.color_yellow then
		meta:set_string("color", "yellow")
	elseif fields.r0 then
		meta:set_string("rotation", "r0")
	elseif fields.r90 then
		meta:set_string("rotation", "r90")
	elseif fields.r180 then
		meta:set_string("rotation", "r180")
	elseif fields.r270 then
		meta:set_string("rotation", "r270")
	elseif fields.prevpage then
		meta:set_int("page", meta:get_int("page") - 1)
	elseif fields.nextpage then
		meta:set_int("page", meta:get_int("page") + 1)
	elseif fields.noselection then
		meta:set_string("selection", "")
	elseif fields.color_asphalt then
		if clear_selection then
			meta:set_string("selection", "")
		end
		meta:set_string("category", "asphalt")
		meta:set_int("tab", 5)
	elseif fields.lock then
		meta:set_int("locked", 1)
	elseif fields.unlock then
		meta:set_int("locked", 0)
	elseif fields.turn_creative_on then
		meta:set_int("creative_enabled", 1)
	elseif fields.turn_creative_off then
		meta:set_int("creative_enabled", 0)
	elseif fields.turn_clear_on then
		meta:set_int("clear_selection", 1)
	elseif fields.turn_clear_off then
		meta:set_int("clear_selection", 0)
	elseif fields["streets:asphalt_red"] then
		if creative_enabled then
			local stack = ItemStack("streets:asphalt_red")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		else
			meta:set_string("selection", "streets:asphalt_red")
		end
	elseif fields["streets:asphalt_blue"] then
		if creative_enabled then
			local stack = ItemStack("streets:asphalt_blue")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		else
			meta:set_string("selection", "streets:asphalt_blue")
		end
	elseif fields["streets:sidewalk"] then
		if creative_enabled then
			local stack = ItemStack("streets:sidewalk")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		else
			meta:set_string("selection", "streets:sidewalk")
		end
	else
		for k, v in pairs(streets.signs.sections) do
			if fields[v.name] then
				if clear_selection then
					meta:set_string("selection", "")
				end
				meta:set_string("section", v.name)
				meta:set_string("category", "signs")
				meta:set_int("tab", 5)
			end
		end
		for k, v in pairs(streets.labels.sections) do
			if fields[v.name] then
				if clear_selection then
					meta:set_string("selection", "")
				end
				meta:set_string("section", v.name)
				meta:set_string("category", "labels")
				meta:set_int("tab", 5)
			end
		end
		for k, v in pairs(streets.signs.signtypes) do
			v = "streets:" .. v.name
			if fields[v] then
				if creative_enabled then
					local stack = ItemStack(v)
					if inv:room_for_item("main", stack) then
						inv:add_item("main", stack)
					end
				else
					meta:set_string("selection", v)
				end
			end
		end
		for k, v in pairs(minetest.registered_tools) do
			if fields[k] and k:sub(1,13) == "streets:tool_" then
				if creative_enabled then
					local stack = ItemStack(k)
					if inv:room_for_item("main", stack) then
						inv:add_item("main", stack)
					end
				else
					meta:set_string("selection", k)
				end
			end
		end
	end
end

local enough_supply = function(pos, selection)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if streets.signs.signtypes[selection] then
		local sign = streets.signs.signtypes[selection]
		for _, dye in ipairs(streets.dyes) do
			if sign.dye_needed[dye.color] and meta:get_float(dye.color .. "_storage") < sign.dye_needed[dye.color] * 0.05 then
				return false
			end
		end
		if inv:get_stack("sign_input", 1):get_name() == "default:sign_wall_steel"
				and inv:get_stack("sign_input", 1):get_count() >= 1 then
			return true
		end
	elseif selection:sub(1,13) == "streets:tool_" then
		selection = selection:sub(14)
		local markingcolor
		if selection:find("white") then
			markingcolor = "white"
		elseif selection:find("yellow") then
			markingcolor = "yellow"
		end
		selection = selection:gsub("white", "{color}")
		selection = selection:gsub("yellow", "{color}")
		selection = selection:gsub("_r90", "")
		selection = selection:gsub("_r180", "")
		selection = selection:gsub("_r270", "")
		local dye_needed = streets.labels.labeltypes[selection].dye_needed * 0.05
		if meta:get_float(markingcolor .. "_storage") >= dye_needed
				and inv:get_stack("steel_input", 1):get_name() == "default:steel_ingot"
				and inv:get_stack("steel_input", 1):get_count() >= 1 then
			return true
		end
	elseif selection == "streets:asphalt_red"
			and	meta:get_float("red_storage") >= 0.05
			and inv:get_stack("asphalt_input", 1):get_name() == "streets:asphalt"
			and inv:get_stack("asphalt_input", 1):get_count() >= 1 then
		return true
	elseif selection == "streets:asphalt_blue"
			and	meta:get_float("blue_storage") >= 0.05
			and inv:get_stack("asphalt_input", 1):get_name() == "streets:asphalt"
			and inv:get_stack("asphalt_input", 1):get_count() >= 1 then
		return true
	elseif selection == "streets:sidewalk"
			and	meta:get_float("white_storage") >= 0.05
			and inv:get_stack("asphalt_input", 1):get_name() == "streets:asphalt"
			and inv:get_stack("asphalt_input", 1):get_count() >= 1 then
		return true
	end
	return false
end

local remove_supply = function(pos, selection)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if streets.signs.signtypes[selection] then
		local sign = streets.signs.signtypes[selection]
		for _, dye in ipairs(streets.dyes) do
			if sign.dye_needed[dye.color] then
				meta:set_float(dye.color .. "_storage", meta:get_float(dye.color .. "_storage") - sign.dye_needed[dye.color] * 0.05)
			end
		end
		inv:remove_item("sign_input", { name = "default:sign_wall_steel", count = 1 })
	elseif selection:sub(1,13) == "streets:tool_" then
		selection = selection:sub(14)
		local markingcolor
		if selection:find("white") then
			markingcolor = "white"
		elseif selection:find("yellow") then
			markingcolor = "yellow"
		end
		selection = selection:gsub("white", "{color}")
		selection = selection:gsub("yellow", "{color}")
		selection = selection:gsub("_r90", "")
		selection = selection:gsub("_r180", "")
		selection = selection:gsub("_r270", "")
		local dye_needed = streets.labels.labeltypes[selection].dye_needed * 0.05
		meta:set_float(markingcolor .. "_storage", meta:get_float(markingcolor .. "_storage") - dye_needed)
		inv:remove_item("steel_input", { name = "default:steel_ingot", count = 1 })
	elseif selection == "streets:asphalt_red" then
		meta:set_float("red_storage", meta:get_float("red_storage") - 0.05)
		inv:remove_item("asphalt_input", { name = "streets:asphalt", count = 1 })
	elseif selection == "streets:asphalt_blue" then
		meta:set_float("blue_storage", meta:get_float("blue_storage") - 0.05)
		inv:remove_item("asphalt_input", { name = "streets:asphalt", count = 1 })
	elseif selection == "streets:sidewalk" then
		meta:set_float("white_storage", meta:get_float("white_storage") - 0.05)
		inv:remove_item("asphalt_input", { name = "streets:asphalt", count = 1 })
	end
end

local can_dig = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local dye_empty = true
	for _, dye in ipairs(streets.dyes) do
		if not inv:is_empty(dye.color .. "_dye") then
			dye_empty = false
		end
	end
	return dye_empty and inv:is_empty("sign_input") and inv:is_empty("steel_input") and inv:is_empty("asphalt_input") and inv:is_empty("output")
end

local on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
end

local on_metadata_inventory_put = function(pos, listname, index, stack, player)
end

local on_metadata_inventory_take = function(pos, listname, index, stack, player)
end

local allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end

local allow_metadata_inventory_put  = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if meta:get_int("locked") == 1 and minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	if listname == "steel_input" and stack:get_name() == "default:steel_ingot" then
		return stack:get_count()
	elseif listname == "sign_input" and stack:get_name() == "default:sign_wall_steel" then
		return stack:get_count()
	elseif listname == "asphalt_input" and stack:get_name() == "streets:asphalt" then
		return stack:get_count()
	elseif listname == "trash" then
		return -1
	else
		for _, dye in ipairs(streets.dyes) do
			if listname == dye.color .. "_dye" and stack:get_name() == "dye:" .. dye.color then
				return stack:get_count()
			end
		end
		return 0
	end
end

local allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if meta:get_int("locked") == 1 and minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end


ts_workshop.register_workshop("streets", "workshop", {
	description = "Streets Workshop (New)",
	tiles = {
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
		"default_steel_block.png^(streets_asphalt.png^[opacity:200)",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, oddly_breakable_by_hand = 2 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, -0.3125, 0.5 }, -- NodeBox1
			{ -0.5, -0.5, -0.5, -0.375, 0.5, 0.5 }, -- NodeBox2
			{ 0.375, -0.5, -0.5, 0.5, 0.5, 0.5 }, -- NodeBox3
			{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- NodeBox4
			{ -0.5, 0.3125, -0.4375, 0.5, 0.4375, -0.3125 }, -- NodeBox5
		}
	},
	selection_box = {
		type = "regular"
	},
	sounds = default.node_sound_wood_defaults(),
	on_construct = on_construct,
	on_receive_fields = on_receive_fields,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	can_dig = can_dig,
	enough_supply = enough_supply,
	remove_supply = remove_supply,
	update_inventory = update_inventory,
	update_formspec = update_formspec,
})

minetest.register_craft({
	output = "streets:workshop",
	recipe = {
		{ "streets:asphalt", "streets:asphalt", "streets:asphalt" },
		{ "streets:asphalt", "default:mese_crystal_fragment", "streets:asphalt" },
		{ "streets:asphalt", "streets:asphalt", "streets:asphalt" },
	}
})

minetest.register_alias("streets:asphalt_workshop", "streets:workshop")
minetest.register_alias("streets:sign_workshop", "air")