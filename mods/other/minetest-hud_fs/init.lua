--
-- hud_fs: Render formspecs into HUDs
--
-- Copyright © 2021 by luk3yx
--

local hud_fs = {}
local modname = minetest.get_current_modname()
_G[modname] = hud_fs

local DEBUG = false
local DEFAULT_SCALE = 64
local DEFAULT_Z_INDEX = 0

local floor, type, pairs = math.floor, type, pairs
local max, min = math.max, math.min
local legacy_type_field = not minetest.features.hud_def_type_field

-- Attempt to use modlib's parser
local colorstring_to_number
if minetest.global_exists("modlib") and (modlib.version or 0) >= 54 then
    local pcall, from_string = pcall, modlib.minetest.colorspec.from_string
    function colorstring_to_number(col)
        local ok, spec = pcall(from_string, col)
        if not ok or not spec then return end
        return spec:to_number_rgb()
    end
else
    colorstring_to_number = dofile(minetest.get_modpath(modname) ..
        "/colorstring_to_number.lua")
end

hud_fs.colorstring_to_number = colorstring_to_number

-- Hacks to allow colorize() to work to some extent on labels
local function get_label_number(label, style)
    local number, text = label:match("^\027%(c@([^%)]+)%)(.*)$")

    -- Remove trailing escape sequence added by minetest.colorize().
    if text then
        text = text:gsub("\027%(c@[^%)]+%)$", "")
    end

    return text or label, number and colorstring_to_number(number) or
        (style.textcolor and colorstring_to_number(style.textcolor) or 0xFFFFFF)
end

-- Disable the race condition workaround in 5.4.1 singleplayer
-- The bug was fixed in 5.4.1 but there's no (easy) way to detect 5.4.1 clients
-- The workaround is disabled for 5.5.0+ clients (if the server is 5.5.0+)
-- regardless of this setting.
local enable_race_condition_workaround = true
if minetest.is_singleplayer() then
    local version = minetest.get_version()
    if version.project == "Minetest" and version.string == "5.4.1" then
        enable_race_condition_workaround = false
    end
end

local PLUS, TIMES = ("+*"):byte(1, 2)
local function get_font_size(style)
    local size = style.font_size
    if not size then return end

    local first_char = size:byte(1)
    if first_char == TIMES then
        size = tonumber(size:sub(2))
    else
        -- Approximate a multiple size based on the font size
        if first_char == PLUS then
            size = tonumber(size:sub(2))
            if size then
                size = size + 16
            end
        else
            size = tonumber(size)
        end

        if size then
            size = size / 16
        end
    end

    return size and {x = size, y = 0}
end

local empty_table = {}
local function get_style(node, styles_by_name, styles_by_type)
    local style = styles_by_name[node.name]
    if not style then
        return styles_by_type[node.type] or empty_table
    end

    return setmetatable(style, {__index = styles_by_type[node.type]})
end

local function style_is_yes(value, default)
    if value == nil then
        return default
    elseif type(value) == "string" then
        return minetest.is_yes(value)
    else
        return value
    end
end

local font_style_flags = {"bold", "italic", "mono"}
local function get_style_flags(style)
    local flags = 0
    if style.font then
        local options = style.font:split(",")
        for i, flag in ipairs(font_style_flags) do
            if table.indexof(options, flag) > 0 then
                flags = flags + 2 ^ (i - 1)
            end
        end
    end
    return flags
end

local nodes = {}
function nodes.label(node, scale, _, _, _, _, styles_by_type)
    local style = styles_by_type.label or empty_table
    local text, number = get_label_number(node.label, style)
    local elem = {
        type = "text",
        text = text,
        alignment = {x = 1, y = 0},
        number = number,
        size = get_font_size(style),
        style = get_style_flags(style),
    }

    -- Hack for newlines. This will unfortunately break if the font size is
    -- changed from the default.
    if elem.text:find('[\r\n]') then
        elem.alignment.y = 1
        node.y = node.y - 10 / scale
    end
    return elem
end

local log2_div = math.log(2)
function nodes.image(node, scale, _, possibly_using_gles, client_hud_scale)
    -- The provided texture could be any size so this has to scale it first
    local w = floor(node.w * scale * client_hud_scale)
    local h = floor(node.h * scale * client_hud_scale)

    local texture = node.texture_name
    if w > 0 and h > 0 and texture ~= "" then
        texture = "(" .. texture .. ")^[resize:" .. w .. "x" .. h
    else
        -- Minetest throws an error with zero-width HUD images, use blank.png
        -- to keep the image around (for future HUD update calls) while
        -- silencing the error.
        texture = "blank.png"
    end

    -- Hacks to work around textures being aligned to a power of 2 on some
    -- video drivers
    if possibly_using_gles then
        local true_w = 2 ^ math.ceil(math.log(w) / log2_div)
        local true_h = 2 ^ math.ceil(math.log(h) / log2_div)
        if true_w ~= w or true_h ~= h then
            texture = ("[combine:%sx%s:0,0=%s"):format(
                true_w, true_h,
                texture:gsub("\\", "\\\\"):gsub("%^", "\\^"):gsub(":", "\\:")
            )
        end
    end

    return {
        type = "image",
        text = texture,
        alignment = {x = 1, y = 1},
        scale = {x = 1 / client_hud_scale, y = 1 / client_hud_scale},
    }
end

-- Hack box[] into image[]
function nodes.box(node, scale)
    local col = node.color
    -- Add default transparency
    if col:byte(1) == 35 then
        if #col == 4 then
            col = col:gsub("[^#]", "%1%1") .. "8C"
        elseif #col == 7 then
            col = col .. "8C"
        end
    end

    -- Since hud_fs_box.png is guaranteed to be 1x1, scale can be used directly
    return {
        type = "image",
        text = 'hud_fs_box.png^[colorize:' .. col,
        alignment = {x = 1, y = 1},
        scale = {x = node.w * scale, y = node.h * scale},
    }
end

function nodes.textarea(node, scale, add_node, _, _, styles_by_name,
        styles_by_type)
    -- Add in separate nodes for the label and background
    if node.label and node.label ~= "" then
        add_node("label", {
            x = node.x,
            y = node.y - 10 / scale,
            label = node.label
        })
    end

    local style = get_style(node, styles_by_name, styles_by_type)
    if node.name and node.name ~= "" and style_is_yes(style.border, true) then
        add_node("box", {
            x = node.x,
            y = node.y,
            w = node.w,
            h = node.h,
            color = "#757575FF"
        })
    end
    node.x = node.x + 5 / scale
    node.y = node.y + 3 / scale
    local lines = (node.default or ""):split("\n", true)
    local max_line_length = node.w * scale / 8
    for i, line in ipairs(lines) do
        lines[i] = minetest.wrap_text(line, max_line_length)
    end
    return {
        type = "text",
        text = table.concat(lines, "\n"),
        alignment = {x = 1, y = 1},
        number = 0xFFFFFF,
        scale = {x = node.w * scale, y = node.h * scale},
        size = get_font_size(style),
        style = get_style_flags(style),
    }
end

local function get_tile_image(tiles, preferred_texture)
    local tile
    for i = preferred_texture, 1, -1 do
        tile = tiles[i]
        if tile then break end
    end
    if type(tile) == "table" then tile = tile.name end
    if type(tile) ~= "string" then tile = "unknown_item.png" end
    return tile
end

function nodes.item_image(node, ...)
    local def = minetest.registered_items[node.item_name]
    if not def then
        node.texture_name = "unknown_item.png"
    elseif def.inventory_image and def.inventory_image ~= "" then
        node.texture_name = def.inventory_image
    elseif def.wield_image and def.wield_image ~= "" then
        node.texture_name = def.wield_image
    elseif def.tiles then
        node.texture_name = minetest.inventorycube(
            get_tile_image(def.tiles, 1),
            get_tile_image(def.tiles, 6),
            get_tile_image(def.tiles, 3)
        )
    else
        node.texture_name = "unknown_node.png"
    end
    return nodes.image(node, ...)
end

function nodes.button(node, _, add_node, _, _, styles_by_name, styles_by_type)
    local style = get_style(node, styles_by_name, styles_by_type)

    -- This function is used by image_button and item_image_button as well
    if node.drawborder or (node.drawborder == nil and
            style_is_yes(style.border, true)) then
        add_node("box", {
            x = node.x,
            y = node.y,
            w = node.w,
            h = node.h,
            color = "#515151FF"
        })
    end

    if style.bgimg then
        add_node("image", {
            x = node.x,
            y = node.y,
            w = node.w,
            h = node.h,
            texture_name = style.bgimg,
        })
    end

    if node.texture_name and node.texture_name ~= "" then
        add_node("image", node)
    elseif node.item_name and node.item_name ~= "" then
        add_node("item_image", node)
    end
    node.x = node.x + node.w / 2
    node.y = node.y + node.h / 2
    local text, number = get_label_number(node.label, style)
    return {
        type = "text",
        text = text,
        alignment = {x = 0, y = 0},
        number = number,
        size = get_font_size(style),
        style = get_style_flags(style),
    }
end
nodes.button_exit = nodes.button
nodes.image_button = nodes.button
nodes.image_button_exit = nodes.button
nodes.item_image_button = nodes.button

-- Used to decide which element types to pass through as-is
-- "image" is a special case and is not included here
local hud_elem_types = {
    text = true, statbar = true, inventory = true, waypoint = true,
    image_waypoint = true, compass = true, minimap = true,
}

local function render_error(err)
    minetest.log("error", "[hud_fs] Error rendering HUD: " .. tostring(err))
    return {}
end

local function render(tree, possibly_using_gles, scale, z_index, window)
    if type(tree) == "string" then
        local err
        tree, err = formspec_ast.parse(tree)
        if not tree then
            return render_error(err)
        end
    end

    tree = formspec_ast.flatten(tree)
    -- if (tree.formspec_version or 1) < 2 then
    --     return render_error("Formspec version 1 is not supported!")
    -- end

    local hud_elems = {}
    local size_w, size_h = 0, 0
    local pos = {x = 0.5, y = 0.5}
    local offset_x, offset_y = 0, 0
    scale = scale or DEFAULT_SCALE
    z_index = z_index or DEFAULT_Z_INDEX

    local styles_by_name = {}
    local styles_by_type = {}
    local client_hud_scale = window and window.real_hud_scaling or 1
    local function add_node(node_type, node)
        local elem = nodes[node_type](node, scale, add_node,
            possibly_using_gles, client_hud_scale, styles_by_name,
            styles_by_type)
        elem.position = pos
        elem.z_index = z_index
        elem.offset = {
            x = (node.x + offset_x) * scale,
            y = (node.y + offset_y) * scale
        }

        -- Convert to legacy type field
        if legacy_type_field then
            elem.hud_elem_type = elem.type
            elem.type = nil
        end

        hud_elems[#hud_elems + 1] = elem
        z_index = z_index + 1
    end

    for _, node in ipairs(tree) do
        local node_type = node.type
        if node_type == "size" then
            size_w, size_h = node.w, node.h
            offset_x, offset_y = -size_w / 2, -size_h / 2
        elseif node_type == "position" then
            pos = {x = node.x, y = node.y}
        elseif node_type == "anchor" then
            if size_w == 0 or size_h == 0 then
                return render_error("anchor[] without size[]")
            end
            offset_x = -node.x * size_w
            offset_y = -node.y * size_h
        elseif node_type == "padding" and window then
            if size_w == 0 or size_h == 0 then
                return render_error("padding[] without size[]")
            elseif #hud_elems > 0 then
                return render_error("padding[] after other elements")
            end

            -- If padding[] is present, override the specified scale on new
            -- clients
            scale = min(
                -- The client's size
                window.size.x / (window.max_formspec_size.x * 1.1),
                window.size.y / (window.max_formspec_size.y * 1.1),

                -- Maximum size based on the padding
                window.size.x * (1 - node.x * 2) / size_w,
                window.size.y * (1 - node.y * 2) / size_h
            ) / client_hud_scale
        elseif node_type == "style" or node_type == "style_type" then
            local styles = node_type == "style" and styles_by_name or
                styles_by_type
            for _, name in ipairs(node.selectors or {node.name}) do
                local props = styles[name]
                if not props then
                    props = {}
                    styles[name] = props
                end
                for k, v in pairs(node.props) do
                    if v == "" then
                        props[k] = nil
                    else
                        props[k] = v
                    end
                end
            end
        elseif hud_elem_types[node_type] or (node_type == "image" and
                node.texture_name == nil and node.text ~= nil) then
            -- Pass through new HUD elements with type = "hud_type"
            hud_elems[#hud_elems + 1] = node

            -- Support new type field on MT 5.8 and older
            if legacy_type_field then
                node.hud_elem_type = node.type
                node.type = nil
            end
        elseif nodes[node_type] then
            add_node(node_type, node)
        elseif node_type == nil and node.hud_elem_type then
            -- Pass through legacy HUD elements
            hud_elems[#hud_elems + 1] = node

            -- Suppress deprecation warning for using "hud_elem_type", it may
            -- still be useful for element types that hud_fs doesn't know about
            -- yet
            if not legacy_type_field then
                node.type = node.hud_elem_type
                node.hud_elem_type = nil
            end
        end
    end

    return hud_elems
end

local hud_elems = {}
--[[
hud_elems[player_name][formname] = {
    {List of HUD IDs},
    {List of HUD definitions}
}
]]

-- Returns needs_replacing, differences
local function compare_elems(old_elem, new_elem)
    local differences = {}
    for k, v in pairs(old_elem) do
        local v2 = new_elem[k]
        if type(v) == "table" and type(v2) == "table" then
            -- Tables are guaranteed to be vectors at the moment, don't bother
            -- checking anything else to improve performance.
            if v.x ~= v2.x or v.y ~= v2.y or v.z ~= v2.z then
                differences[#differences + 1] = k
            end
        elseif v ~= v2 then
            -- Sometimes the HUD element will need to be deleted/re-added.
            if k == "type" or k == "hud_elem_type" or v2 == nil then
                return true, nil
            end
            differences[#differences + 1] = k
        end
    end

    -- Check for missing keys in old_elem
    for k in pairs(new_elem) do
        if old_elem[k] == nil then
            differences[#differences + 1] = k
        end
    end

    return false, differences
end

local function reshow_hud(name, formname, data)
    if not hud_elems[name] or hud_elems[name][formname] ~= data then
        return
    end

    data[3] = nil
    local fs = data[4]
    if fs then
        data[4] = nil
        hud_fs.show_hud(name, formname, fs)
    end
end

local scales = {}
local z_indexes = {}
function hud_fs.show_hud(player, formname, formspec)
    if type(player) == "string" then
        player = minetest.get_player_by_name(player)
        if not player then return end
    end

    local name = player:get_player_name()
    if not hud_elems[name] then
        hud_elems[name] = {}
    end

    -- Work around Minetest bug (should be fixed in 5.4)
    local info = minetest.get_player_information(name)
    if not info then return end

    local data = hud_elems[name][formname]
    if not data then
        data = {{}, {}}
        hud_elems[name][formname] = data
    end
    local proto_ver = info.protocol_version

    -- Work around client-side race conditions in MT <= 5.4.0
    if proto_ver < 40 and data[3] then
        data[4] = formspec
        return
    end

    -- MultiCraft-specific detection of clients which may be using OpenGL ES 1
    local possibly_using_gles = (info.platform == "Android" or
        info.platform == "iOS")

    local ids, elems = data[1], data[2]
    local window = minetest.get_player_window_information and
        minetest.get_player_window_information(name)
    local new_elems = render(formspec, possibly_using_gles, scales[formname],
        z_indexes[formname], window)

    -- Z-index was added to MT 5.2.0 (protocol version 39) and is ignored by
    -- older clients. Because of the way HUDs work, sometimes it's safest to
    -- just delete and re-add every single element for these older clients.
    if proto_ver < 39 then
        -- Maybe we can get away with just doing hud_change() and not resending
        local diff_cache = {}
        local can_update = true
        local update_packets = max(#elems - #new_elems, 0)
        for i, new_elem in ipairs(new_elems) do
            local old_elem = elems[i]
            if old_elem then
                local needs_replacing, diff = compare_elems(old_elem, new_elem)
                if needs_replacing then
                    can_update = false
                    break
                end
                if #diff > 0 then
                    diff_cache[i] = diff
                    update_packets = update_packets + 1
                end
            else
                -- If elements are added the whole HUD needs to be resent.
                can_update = false
                break
            end
        end

        local resend_packets = #elems + #new_elems
        if can_update and resend_packets >= update_packets then
            -- Send lots of hud_change packets
            for i, new_elem in ipairs(new_elems) do
                local diff = diff_cache[i]
                if diff then
                    for _, stat in ipairs(diff) do
                        player:hud_change(ids[i], stat, new_elem[stat])
                    end
                    elems[i] = new_elem
                end
            end

            -- Remove any extra elements
            for i = #new_elems + 1, #ids do
                player:hud_remove(ids[i])
                ids[i] = nil
                elems[i] = nil
            end

            if DEBUG then
                minetest.chat_send_player(name, "[DEBUG] Sent " ..
                    update_packets .. " packet(s) using hud_change() and " ..
                    "hud_remove() to update HUD")
            end
        else
            -- Or resend every single HUD element
            for i = 1, #ids do
                player:hud_remove(ids[i])
                ids[i] = nil
                elems[i] = nil
            end
            for i, elem in ipairs(new_elems) do
                ids[i] = player:hud_add(elem)
                elems[i] = elem
            end

            -- Block future HUD modifications if the new HUD isn't empty
            if new_elems[1] and enable_race_condition_workaround then
                data[3] = true
                minetest.after(0.05, reshow_hud, name, formname, data)
            end

            if DEBUG then
                minetest.chat_send_player(name, "[DEBUG] Sent " ..
                    resend_packets .. " packet(s) resending entire HUD")
            end
        end
        return
    end

    -- As MT 5.2.0+ clients support z_index, the HUD IDs don't need to be
    -- sequential and the update packets can therefore be more efficient.
    local replaced, modified, modify_packets, added = 0, 0, 0, 0
    for i, new_elem in ipairs(new_elems) do
        local old_elem = elems[i]
        if old_elem then
            local needs_replacing, diff = compare_elems(old_elem, new_elem)
            if needs_replacing or #diff > 2 then
                -- Resend the entire element if there are more than two
                -- differences as this only sends two packets to the client.
                player:hud_remove(ids[i])
                ids[i] = player:hud_add(new_elem)
                replaced = replaced + 1
            else
                -- Otherwise it's more efficient to use multiple hud_change()
                -- calls (this is a no-op if #diff == 0).
                for _, stat in ipairs(diff) do
                    player:hud_change(ids[i], stat, new_elem[stat])
                    modify_packets = modify_packets + 1
                end
                if #diff > 0 then modified = modified + 1 end
            end
        else
            ids[i] = player:hud_add(new_elem)
            added = added + 1
        end
        elems[i] = new_elem
    end

    -- Remove any extra elements
    local removed = 0
    for i = #new_elems + 1, #ids do
        player:hud_remove(ids[i])
        ids[i] = nil
        elems[i] = nil
        removed = removed + 1
    end

    -- Only block future HUD modifications if any elements have been added
    if proto_ver < 40 and added > 0 and enable_race_condition_workaround then
        data[3] = true
        minetest.after(0.05, reshow_hud, name, formname, data)
    end

    if DEBUG then
        local packets = modify_packets + replaced * 2 + added + removed
        minetest.chat_send_player(name, "[DEBUG] Sent " .. packets ..
            " network packet(s): Modified " .. modified ..
            " elements in-place (for " .. modify_packets ..
            " packet(s)), replaced " .. replaced .. ", added " .. added ..
            " and removed " .. removed .. " element(s).")
    end
end

function hud_fs.close_hud(player, formname)
    hud_fs.show_hud(player, formname, {})
end

minetest.register_on_leaveplayer(function(player)
    hud_elems[player:get_player_name()] = nil
end)

-- Sets the base z-index for formname. Should not be done when the formspec is
-- open. Note that this is not used for all elements, if the formspec contains
-- 10 HUD elements it will use a z-index ranging from z_index to z_index + 9.
-- This has no effect for clients older than 5.2.0.
function hud_fs.set_z_index(formname, z_index)
    if z_index == DEFAULT_Z_INDEX then z_index = nil end
    z_indexes[formname] = z_index
end

-- Sets the scale for formname. This can be done when the HUD is open, however
-- the scale won't be changed for existing formspecs.
function hud_fs.set_scale(formname, scale)
    if scale == DEFAULT_SCALE then scale = nil end
    scales[formname] = scale
end

-- Testing
--[=[
if not DEBUG then return end

local using_fs = {}
local function poll()
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local fs = "formspec_version[3]" ..
            "size[4,4.5] position[1,0] anchor[1,0] no_prepend[]" ..
            "bgcolor[#00000022;true]" ..
            "box[0,0;5,2;#380C2AFF]" ..
            "label[0.25,0.5;This is a test HUD]" ..
            "label[0.25,1;" .. minetest.colorize("#00ffff", "Server uptime: " ..
                floor(minetest.get_server_uptime()) .. " seconds") ..
                "]" ..
            "label[0.25,1.5;Run /hud to interact!]"
        if math.random(0, 1) == 0 then
            fs = fs .. "image[3,1.5;1,1;default_dirt.png]"
        end
        -- if math.random(1, 5) > 1 then
        --     fs = fs .. "label[0,1.5;Second label (test)\nNewline test\rabc]"
        -- end
        fs = fs ..
            "box[0,2;5,2;#380C2ABF]" ..
            "container[0,2.5]" ..
                "item_image[0,0;1,1;carts:rail]" ..
                "item_image[1,0;1,1;default:dirt_with_grass]" ..
                "container[2,-0.5]" ..
                    "item_image[0,0.5;1,1;default:cactus]" ..
                    "item_image[1,0.5;1,1;default:tree]" ..
                "container_end[]" ..
            "container_end[]" ..
            "button[0,4;2,0.5;mrkr;Waypoints]" ..
            "button[2,4;2,0.5;close;Close]"
        if using_fs[name] then
            minetest.show_formspec(name, "hud_fs:uptime", fs)
            hud_fs.close_hud(name, "hud_fs:uptime")
        else
            hud_fs.show_hud(name, "hud_fs:uptime", fs)
        end
    end
end

local function poll_outer()
    poll()
    minetest.after(1, poll_outer)
end
minetest.register_on_mods_loaded(poll_outer)

minetest.register_chatcommand("hud", {
    func = function(name, _)
        using_fs[name] = true
        poll()
    end,
})

minetest.register_chatcommand("hud2", {
    func = function(name, _)
        minetest.show_formspec(name, "hud_fs:uptime", "formspec_version[3]" ..
            "size[4,4.5] position[1,0] anchor[1,0] no_prepend[]" ..
            "bgcolor[#ff000000;neither;#00ff0000]" ..
            "button[0,4;2,0.5;mrkr;Waypoints]" ..
            "button[2,4;2,0.5;close;Close]")
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "hud_fs:uptime" then return end
    local name = player:get_player_name()
    if fields.mrkr then
        minetest.registered_chatcommands["mrkr"].func(name, "")
    elseif fields.close then
        minetest.close_formspec(name, "hud_fs:uptime")
    elseif not fields.quit then
        return
    end

    using_fs[name] = nil
    poll()
end)
]=]
