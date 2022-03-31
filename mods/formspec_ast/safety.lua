--
-- formspec_ast: An abstract system tree for formspecs.
--
-- This verifies that formspecs from untrusted sources are safe(-ish) to
-- display, provided they are passed through formspec_ast.interpret.
--
-- The MIT License (MIT)
--
-- Copyright © 2019 by luk3yx.
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

-- Similar to ast.walk(), however returns {} and then exits if walk() would
-- crash. Use this for untrusted formspecs, otherwise use walk() for speed.
local function safe_walk(tree)
    local walk = formspec_ast.walk(tree)
    local seen = {}
    return function()
        if not walk or not seen then return end

        local good, msg = pcall(walk)
        if good and (type(msg) == 'table' or msg == nil) and not seen[msg] then
            if msg then
                seen[msg] = true
            end
            return msg
        else
            return {}
        end
    end
end

-- Similar to ast.flatten(), however removes unsafe elements.
local function safe_flatten(tree)
    local res = {formspec_version = 1}
    if tree.formspec_version == 2 then
        res.formspec_version = 2
    end
    for elem in safe_walk(table.copy(tree)) do
        if elem.type == 'container' then
            if type(elem.x) == 'number' and type(elem.y) == 'number' then
                formspec_ast.apply_offset(elem, elem.x, elem.y)
            end
        elseif elem.type then
            table.insert(res, elem)
        end
    end
    return res
end

local ensure = {}

function ensure.string(obj)
    if obj == nil then
        return ''
    end
    return tostring(obj)
end

function ensure.number(obj, max, min)
    local res = tonumber(obj)
    assert(res ~= nil and res == res)
    assert(res <= (max or 100) and res >= (min or 0))
    return res
end

function ensure.integer(obj)
    return math.floor(ensure.number(obj))
end

local validate
local function validate_elem(obj)
    local template = validate[obj.type]
    assert(type(template) == 'table')
    for k, v in pairs(obj) do
        local func
        if k == 'type' then
            func = ensure.string
        else
            local type_ = template[k]
            if type(type_) == 'string' then
                if type_:sub(#type_) == '?' then
                    type_ = type_:sub(1, #type_ - 1)
                end
                func = ensure[type_]
            elseif type(type_) == 'function' then
                func = type_
            end
        end

        if func then
            obj[k] = func(v)
        else
            obj[k] = nil
        end
    end

    for k, v in pairs(template) do
        if type(v) ~= 'string' or v:sub(#v) ~= '?' then
            assert(obj[k] ~= nil, k .. ' does not exist!')
        end
    end
end

validate = {
    size = {w = 'number', h = 'number'},
    label = {x = 'number', y = 'number', label = 'string'},
    image = {x = 'number', y = 'number', w = 'number', h = 'number',
        texture_name = 'string'},
    button = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string'},
    image_button = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', texture_name = 'string',
        noclip = 'string', drawborder = 'string',
        pressed_texture_name = 'string'},
    item_image_button = {x = 'number', y = 'number', w = 'number',
        h = 'number', name = 'string', label = 'string',
        texture_name = 'string'},
    field = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', default = 'string'},
    pwdfield = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string'},
    field_close_on_enter = {name = 'string', close_on_enter = 'string'},
    textarea = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', default = 'string'},
    dropdown = {
        x = 'number', y = 'number', w = 'number', name = 'string',
        items = function(items)
            assert(type(items) == 'list')
            for k, v in pairs(items) do
                assert(type(k) == 'number' and type(v) == 'string')
            end
        end,
        selected_idx = 'integer',
    },
    checkbox = {x = 'number', y = 'number', name = 'string', label = 'string',
        selected = 'string'},
    box = {x = 'number', y = 'number', w = 'number', h = 'number',
        color = 'string'},

    list = {
        inventory_location = function(location)
            assert(location == 'current_node' or location == 'current_player')
            return location
        end,
        list_name = 'string', x = 'number', y = 'number', w = 'number',
        h = 'number', starting_item_index = 'number?',
    },
    listring = {},
}

validate.vertlabel = validate.label
validate.button_exit = validate.button
validate.image_button_exit = validate.item_image_button

-- Ensure that an AST tree is safe to display. The resulting tree will be
-- flattened for simplicity.
function formspec_ast.safe_parse(tree, custom_handlers)
    if type(tree) == 'string' then
        tree = formspec_ast.parse(tree, custom_handlers)
    end

    if type(tree) ~= 'table' then
        return {}
    end

    -- Flatten the tree and remove objects that can't possibly be elements.
    tree = safe_flatten(tree)

    -- Iterate over the tree and add valid elements to a new table.
    local res = {formspec_version = tree.formspec_version}
    for i, elem in ipairs(tree) do
        local good, msg = pcall(validate_elem, elem)
        if good then
            res[#res + 1] = elem
        end
    end

    return res
end

function formspec_ast.safe_interpret(tree)
    return formspec_ast.unparse(formspec_ast.safe_parse(tree))
end
