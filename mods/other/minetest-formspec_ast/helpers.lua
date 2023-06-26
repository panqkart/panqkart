--
-- formspec_ast: An abstract syntax tree for formspecs.
--
-- This does not actually depend on Minetest and could probably run in
-- standalone Lua.
--
-- The MIT License (MIT)
--
-- Copyright © 2019-2022 by luk3yx.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
--

local formspec_ast, minetest = formspec_ast, formspec_ast.minetest

-- Expose minetest.formspec_escape for use outside of Minetest
formspec_ast.formspec_escape = minetest.formspec_escape

-- Parses and unparses plain formspecs and just unparses AST trees.
function formspec_ast.interpret(spec, custom_handlers)
    local ast = spec
    if type(spec) == 'string' then
        local err
        ast, err = formspec_ast.parse(spec, custom_handlers)
        if not ast then
            return nil, err
        end
    end
    return formspec_ast.unparse(ast)
end

local function walk_inner(tree, container_elems)
    local parents = {}
    local i = 1
    return function()
        local res = tree[i]
        while not res do
            local n = table.remove(parents)
            if not n then
                return
            end
            tree, i = n[1], n[2]
            res = tree[i]
        end
        i = i + 1

        if container_elems[res.type] then
            table.insert(parents, {tree, i})
            tree = res
            i = 1
        end
        return res
    end
end

-- Returns an iterator over all nodes in a formspec AST, including ones in
-- containers.
local container_elems = {container = true, scroll_container = true}
function formspec_ast.walk(tree)
    return walk_inner(tree, container_elems)
end

-- Similar to formspec_ast.walk(), however only returns nodes which have a type
-- of `node_type`.
function formspec_ast.find(tree, node_type)
    local walk = formspec_ast.walk(tree)
    return function()
        local node
        repeat
            node = walk()
        until node == nil or node.type == node_type
        return node
    end
end

-- Returns the first element in the AST tree that has the given name.
function formspec_ast.get_element_by_name(tree, name)
    for elem in formspec_ast.walk(tree) do
        if elem.name == name then
            return elem
        end
    end
end

-- Returns a table/list/array of all elements in the AST tree that have the
-- given name.
function formspec_ast.get_elements_by_name(tree, name)
    local res = {}
    for elem in formspec_ast.walk(tree) do
        if elem.name == name then
            table.insert(res, elem)
        end
    end
    return res
end

-- Offsets all elements in an element list.
function formspec_ast.apply_offset(elems, x, y)
    x, y = x or 0, y or 0
    for _, elem in ipairs(elems) do
        if type(elem.x) == 'number' and type(elem.y) == 'number' then
            elem.x = elem.x + x
            elem.y = elem.y + y
        end
    end
end

-- Removes container elements and fixes nodes inside containers.
local flatten_containers = {container = true}
function formspec_ast.flatten(tree)
    local res = {formspec_version=tree.formspec_version}
    for elem in walk_inner(table.copy(tree), flatten_containers) do
        if elem.type == 'container' then
            formspec_ast.apply_offset(elem, elem.x, elem.y)
        else
            table.insert(res, elem)
        end
    end
    return res
end

-- Similar to minetest.show_formspec, however is passed through
-- formspec_ast.interpret first and will return an error message if the
-- formspec could not be parsed.
function formspec_ast.show_formspec(player, formname, formspec)
    if minetest.is_player(player) then
        player = player:get_player_name()
    end
    if type(player) ~= 'string' or player == '' then
        return 'No such player!'
    end

    local new_fs, err = formspec_ast.interpret(formspec)
    if new_fs then
        minetest.show_formspec(player, formname, new_fs)
    else
        minetest.log('warning', 'formspec_ast.show_formspec(): ' ..
            tostring(err))
        return err
    end
end

-- Alias invsize[] to size[]
formspec_ast.register_element('invsize', function(raw, parse)
    return {
        type = 'size',
        w = parse.number(raw[1][1]),
        h = parse.number(raw[1][2]),
    }
end)

-- Centered labels
-- Credit to https://github.com/v-rob/minetest_formspec_game for the click
-- animation workaround.
-- This may be removed from a later formspec_ast release.
-- size[5,2]formspec_ast:centered_label[0,0;5,1;Centered label]
formspec_ast.register_element('formspec_ast:centered_label', function(raw,
        parse)
    -- Create a container
    return {
        type = 'container',
        x = parse.number(raw[1][1]),
        y = parse.number(raw[1][2]),

        -- Add a background-less image button with the text.
        {
            type = 'image_button',
            x = 0,
            y = 0,
            w = parse.number(raw[2][1]),
            h = parse.number(raw[2][2]),
            texture_name = 'blank.png',
            name = '',
            label = parse.string(raw[3]),
            noclip = true,
            drawborder = false,
            pressed_texture_name = '',
        },

        -- Add another background-less image button to hack around the click
        -- animation.
        {
            type = 'image_button',
            x = 0,
            y = 0,
            w = parse.number(raw[2][1]),
            h = parse.number(raw[2][2]),
            texture_name = '',
            name = '',
            label = '',
            noclip = true,
            drawborder = false,
            pressed_texture_name = '',
        },
    }
end)

-- Add a formspec element to crash clients
-- This may be removed from a later formspec_ast release.
formspec_ast.register_element('formspec_ast:crash', function(_, _)
    return {
        type = 'list',
        inventory_location = '___die',
        list_name = 'crash',
        x = 0,
        y = 0,
        w = 0,
        h = 0,
    }
end)
