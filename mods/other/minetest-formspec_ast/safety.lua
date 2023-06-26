--
-- formspec_ast: An abstract syntax tree for formspecs.
--
-- This verifies that formspecs from untrusted sources are safe(-ish) to
-- display, provided they are passed through formspec_ast.interpret.
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

-- Similar to ast.walk(), however returns nil if walk() would crash. Use this
-- for untrusted formspecs, otherwise use walk() for speed.
local function safe_walk(tree)
    local walk = formspec_ast.walk(tree)
    local seen = {}
    return function()
        if not walk or not seen then return end

        local good, msg = pcall(walk)
        if good and type(msg) == 'table' and not seen[msg] then
            seen[msg] = true
            return msg
        end
    end
end

-- Similar to ast.flatten(), however removes unsafe elements.
local function safe_flatten(tree)
    local res = {formspec_version = 1}
    if type(tree.formspec_version) == 'number' and
            tree.formspec_version > 1 then
        res.formspec_version = math.min(math.floor(tree.formspec_version), 6)
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
    if obj == nil then return end

    local res = tonumber(obj)
    assert(res ~= nil and res == res)
    assert(res <= (max or 100) and res >= (min or 0))
    return res
end

function ensure.boolean(bool)
    assert(type(bool) == "boolean" or bool == nil)
    return bool
end

function ensure.integer(obj)
    return math.floor(ensure.number(obj))
end

function ensure.texture(obj)
    return ensure.string(obj):match("^[^%[]*")
end

function ensure.list(items)
    assert(type(items) == 'table')
    for k, v in pairs(items) do
        assert(type(k) == 'number' and type(v) == 'string')
    end
    return items
end

function ensure.inventory_location(location)
    assert(location == 'current_node' or location == 'current_player')
    return location
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
            local value_type = template[k]
            if value_type and value_type:sub(-1) == '?' then
                value_type = value_type:sub(1, -2)
            end
            func = ensure[value_type]
        end

        if func then
            obj[k] = func(v)
        else
            obj[k] = nil
        end
    end

    for k, v in pairs(template) do
        if v:sub(-1) ~= '?' then
            assert(obj[k] ~= nil, k .. ' does not exist!')
        end
    end
end

validate = {
    size = {w = 'number', h = 'number'},
    label = {x = 'number', y = 'number', label = 'string'},
    image = {x = 'number', y = 'number', w = 'number', h = 'number',
        texture_name = 'texture'},
    button = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string'},
    image_button = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', texture_name = 'texture',
        noclip = 'string', drawborder = 'string',
        pressed_texture_name = 'texture'},
    item_image_button = {x = 'number', y = 'number', w = 'number',
        h = 'number', name = 'string', label = 'string',
        texture_name = 'texture'},
    field = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', default = 'string'},
    pwdfield = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string'},
    field_close_on_enter = {name = 'string', close_on_enter = 'string'},
    textarea = {x = 'number', y = 'number', w = 'number', h = 'number',
        name = 'string', label = 'string', default = 'string'},
    dropdown = {
        x = 'number', y = 'number', w = 'number', h = 'number?',
        name = 'string', items = 'list', selected_idx = 'integer',
    },
    textlist = {
        x = 'number', y = 'number', w = 'number', h = 'number?',
        name = 'string', listelems = 'list', selected_idx = 'integer?',
        transparent = 'boolean?',
    },
    checkbox = {x = 'number', y = 'number', name = 'string', label = 'string',
        selected = 'string'},
    box = {x = 'number', y = 'number', w = 'number', h = 'number',
        color = 'string'},

    list = {
        inventory_location = 'inventory_location', list_name = 'string',
        x = 'number', y = 'number', w = 'number', h = 'number',
        starting_item_index = 'number?',
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
    for _, elem in ipairs(tree) do
        local good, _ = pcall(validate_elem, elem)
        if good then
            res[#res + 1] = elem
        end
    end

    return res
end
