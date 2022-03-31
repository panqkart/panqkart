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

local floor, type, pairs, max = math.floor, type, pairs, math.max

local colorstring_to_number
local function colorstring_to_number_fallback(col)
    colorstring_to_number_fallback = dofile(minetest.get_modpath(modname) ..
        "/colorstring_to_number.lua")
    return colorstring_to_number_fallback(col)
end

if minetest.colorspec_to_colorstring then
    function colorstring_to_number(col)
        local res = minetest.colorspec_to_colorstring(col)
        if res and (res:byte(1) ~= 35 or #res < 7) then
            -- Unexpected return value, go back to using the fallback parser.
            minetest.log("warning", ("[hud_fs] Unexpected value returned by" ..
                " minetest.colorspec_to_colorstring(%q): %q"):format(col,
                res))
            colorstring_to_number = colorstring_to_number_fallback
            return colorstring_to_number_fallback(col)
        end
        return res and tonumber(res:sub(2, 7), 16)
    end
else
    colorstring_to_number = colorstring_to_number_fallback
end

-- Hacks to allow colorize() to work to some extent on labels
local function get_label_number(label)
    local number, text = label:match("^\027%(c@([^%)]+)%)(.*)$")

    -- Remove trailing escape sequence added by minetest.colorize().
    if text then
        text = text:gsub("\027%(c@[^%)]+%)$", "")
    end

    return text or label, number and colorstring_to_number(number) or 0xFFFFFF
end

local nodes = {}
function nodes.label(node, scale)
    local text, number = get_label_number(node.label)
    local elem = {
        hud_elem_type = "text",
        text = text,
        alignment = {x = 1, y = 0},
        number = number
    }

    -- Hack for newlines. This will unfortunately break if the font size is
    -- changed from the default.
    if elem.text:find('[\r\n]') then
        elem.alignment.y = 1
        node.y = node.y - 10 / scale
    end
    return elem
end

function nodes.image(node, scale, _, proto_ver)
    local w = floor(node.w * scale)
    local h = floor(node.h * scale)
    local elem_scale = {x = 1, y = 1}

    -- Hacks to support MultiCraft
    -- This is horrible and unfortunately is applied to MT clients as well
    if proto_ver == 32 then
        local true_w, true_h = w, h
        w, h = 2 ^ math.ceil(math.log(w, 2)), 2 ^ math.ceil(math.log(h, 2))
        elem_scale.x, elem_scale.y = true_w / max(w, 1), true_h / max(h, 1)
    end

    local texture = node.texture_name
    if w > 0 and h > 0 and texture ~= "" then
        texture = "(" .. texture .. ")^[resize:" .. w .. "x" .. h
    else
        -- Minetest throws an error with zero-width HUD images, use blank.png
        -- to keep the image around (for future HUD update calls) while
        -- silencing the error.
        texture = "blank.png"
    end
    return {
        hud_elem_type = "image",
        text = texture,
        alignment = {x = 1, y = 1},
        scale = elem_scale,
    }
end

-- Hack box[] into image[]
function nodes.box(node, scale, add_node, proto_ver)
    local col = node.color
    -- Add default transparency
    if col:byte(1) == 35 then
        if #col == 4 then
            col = col:gsub("[^#]", "%1%1") .. "8C"
        elseif #col == 7 then
            col = col .. "8C"
        end
    end
    node.texture_name = 'hud_fs_box.png^[colorize:' .. col
    return nodes.image(node, scale, add_node, proto_ver)
end

function nodes.textarea(node, scale, add_node)
    -- Add in separate nodes for the label and background
    if node.label ~= "" then
        add_node("label", {
            x = node.x,
            y = node.y - 10 / scale,
            label = node.label
        })
    end
    if node.name ~= "" then
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
        hud_elem_type = "text",
        text = table.concat(lines, "\n"),
        alignment = {x = 1, y = 1},
        number = 0xFFFFFF,
        scale = {x = node.w * scale, y = node.h * scale}
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

function nodes.item_image(node, scale, add_node, proto_ver)
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
    return nodes.image(node, scale, add_node, proto_ver)
end

function nodes.button(node, _, add_node)
    -- This function is used by image_button and item_image_button as well
    if node.drawborder == nil or node.drawborder then
        add_node("box", {
            x = node.x,
            y = node.y,
            w = node.w,
            h = node.h,
            color = "#515151FF"
        })
    end
    if node.texture_name and node.texture_name ~= "" then
        add_node("image", node)
    elseif node.item_name and node.item_name ~= "" then
        add_node("item_image", node)
    end
    node.x = node.x + node.w / 2
    node.y = node.y + node.h / 2
    local text, number = get_label_number(node.label)
    return {
        hud_elem_type = "text",
        text = text,
        alignment = {x = 0, y = 0},
        number = number
    }
end
nodes.button_exit = nodes.button
nodes.image_button = nodes.button
nodes.image_button_exit = nodes.button
nodes.item_image_button = nodes.button

local render_error
local function render(tree, proto_ver, scale, z_index)
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

    local function add_node(node_type, node)
        local elem = nodes[node_type](node, scale, add_node, proto_ver)
        elem.position = pos
        elem.name = node_type
        elem.z_index = z_index
        elem.offset = {
            x = (node.x + offset_x) * scale,
            y = (node.y + offset_y) * scale
        }
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
            -- return render_error('anchor[] not implemented')
        elseif nodes[node_type] then
            add_node(node_type, node)
        end
    end

    return hud_elems
end

-- Defined as a local before render()
function render_error(err)
    return render("formspec_version[3]size[8,1]label[0,0.5;" ..
        minetest.formspec_escape(tostring(err)) .. "]")
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
            -- Tables are guaranteed to be 2-dimensional vectors at the moment,
            -- don't bother checking anything else to improve performance.
            if v.x ~= v2.x or v.y ~= v2.y then
                differences[#differences + 1] = k
            end
        elseif v ~= v2 then
            -- Sometimes the HUD element will need to be deleted/re-added.
            if k == "hud_elem_type" or v2 == nil then return true, nil end
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

local scales = {}
local z_indexes = {}
function hud_fs.show_hud(player, formname, formspec)
    if type(player) == "string" then
        player = minetest.get_player_by_name(player)
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
    local ids, elems = data[1], data[2]
    local proto_ver = info.protocol_version
    local new_elems = render(formspec, proto_ver, scales[formname],
        z_indexes[formname])

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
