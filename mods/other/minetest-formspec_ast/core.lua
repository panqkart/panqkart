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

local BACKSLASH, SEMICOLON, COMMA, RBRACKET = ('\\;,]'):byte(1, 4)

-- Parse a formspec into a "raw" non-AST state.
-- Input: size[5,2]button[0,0;5,1;name;Label] image[0,1;1,1;air.png]
-- Output:
-- {
--     {type='size', '5', '2'},
--     {type='button', {'0', '0'}, {'5', '1'}, 'name', 'label'},
--     {type='image', {'0', '1'}, {'1', '1'}, 'air.png'},
-- }
local table_concat = table.concat
local function raw_parse(spec)
    local res = {}
    local end_idx = 0
    local bracket_idx
    local spec_length = #spec

    while end_idx < spec_length do
        -- Get the element type
        bracket_idx = spec:find('[', end_idx + 1, true)
        if not bracket_idx then break end
        local parts = {type = spec:sub(end_idx + 1, bracket_idx - 1):trim()}

        -- Split everything
        -- This tries and avoids creating small strings where possible
        end_idx = spec_length + 1
        local part = {}
        local esc = false
        local inner = {}
        local start_idx = bracket_idx + 1
        for idx = bracket_idx, spec_length do
            local byte = spec:byte(idx)
            if esc then
                -- The current character is escaped
                esc = false
            elseif byte == BACKSLASH then
                part[#part + 1] = spec:sub(start_idx, idx - 1)
                start_idx = idx + 1
                esc = true
            elseif byte == SEMICOLON then
                part[#part + 1] = spec:sub(start_idx, idx - 1)
                start_idx = idx + 1
                if #inner > 0 then
                    inner[#inner + 1] = table_concat(part)
                    parts[#parts + 1] = inner
                    inner = {}
                else
                    parts[#parts + 1] = table_concat(part)
                end
                part = {}
            elseif byte == COMMA then
                part[#part + 1] = spec:sub(start_idx, idx - 1)
                start_idx = idx + 1
                inner[#inner + 1] = table_concat(part)
                part = {}
            elseif byte == RBRACKET then
                end_idx = idx
                break
            end
        end

        -- Add the last part
        part[#part + 1] = spec:sub(start_idx, end_idx - 1)
        if #inner > 0 then
            inner[#inner + 1] = table_concat(part)
            parts[#parts + 1] = inner
        else
            parts[#parts + 1] = table_concat(part)
        end

        res[#res + 1] = parts
    end

    return res
end

-- Unparse raw formspecs
-- WARNING: This will modify the table passed to it.
local function raw_unparse(data)
    local res = {}
    for _, parts in ipairs(data) do
        res[#res + 1] = parts.type
        for i = 1, #parts do
            if type(parts[i]) == 'table' then
                for j, e in ipairs(parts[i]) do
                    parts[i][j] = minetest.formspec_escape(e)
                end
                parts[i] = table_concat(parts[i], ',')
            else
                parts[i] = minetest.formspec_escape(parts[i])
            end
        end
        res[#res + 1] = '['
        res[#res + 1] = table_concat(parts, ';')
        res[#res + 1] = ']'
    end
    return table_concat(res)
end

-- Elements
-- The element format is currently not intuitive.
local elements = assert(loadfile(formspec_ast.modpath .. '/elements.lua'))()

-- Parsing
local types = {}

function types.undefined()
    error('Unknown element type!')
end

function types.string(str)
    return str
end

function types.number(raw_num)
    local num = tonumber(raw_num)
    assert(num and num == num, 'Invalid number: "' .. raw_num .. '".')
    return num
end

function types.boolean(bool)
    if bool ~= '' then
        return minetest.is_yes(bool)
    end
end

function types.fullscreen(param)
    if param == 'both' or param == 'neither' then
        return param
    end
    return types.boolean(param)
end

function types.table(obj)
    if obj == '' then return end
    local s, e = obj:find('=', nil, true)
    assert(s, 'Invalid syntax: "' .. obj .. '".')
    return {[obj:sub(1, s - 1)] = obj:sub(e + 1)}
end

function types.null(null)
    assert(null:trim() == '', 'No value expected!')
end

local function parse_value(elems, template)
    local elems_l, template_l = #elems, #template
    if elems_l < template_l or (elems_l > template_l and
            template_l > 0 and template[template_l][2] ~= '...') then
        while #elems > #template and elems[#elems]:trim() == '' do
            elems[#elems] = nil
        end

        assert(#elems == #template, 'Bad element length.')
    end

    local res = {}
    if elems.type then res.type = elems.type end
    for i, obj in ipairs(template) do
        local val
        if obj[2] == '...' then
            assert(template[i + 1] == nil, 'Invalid template!')

            local elems2 = {}
            for j = i, #elems do
                table.insert(elems2, elems[j])
            end
            types['...'](elems2, obj[1], res)
        elseif type(obj[2]) == 'string' then
            local func = types[obj[2]] or types.undefined
            local elem = elems[i]
            if type(elem) == 'table' then
                elem = table_concat(elem, ',')
            end
            res[obj[1]] = func(elem, obj[1])
        else
            local elem = elems[i]
            if type(elem) == 'string' then
                elem = {elem}
            end
            while #obj > #elem do
                table.insert(elem, '')
            end
            val = parse_value(elem, obj)
            for k, v in pairs(val) do
                res[k] = v
            end
        end
    end
    return res
end

types['...'] = function(elems, obj, res)
    local template = {obj}
    local val = {}
    local is_string = type(obj[2]) == 'string'
    for _, elem in ipairs(elems) do
        local n = parse_value({elem}, template)
        if is_string then
            n = n[obj[1]]
        end
        table.insert(val, n)
    end

    if obj[2] == 'table' then
        local t = {}
        for _, n in ipairs(val) do
            if n then
                local k, v = next(n)
                t[k] = v
            end
        end
        res[obj[1]] = t
    elseif type(obj[2]) == 'string' then
        res[obj[1]] = val
    else
        assert(type(val) == 'table')
        res[res.type or 'data'] = val
    end
end

local parse_mt
local function parse_elem(elem, custom_handlers)
    local data = elements[elem.type]
    if not data then
        if not custom_handlers or not custom_handlers[elem.type] then
            return false, 'Unknown element "' .. tostring(elem.type) .. '".'
        end
        local parse = {}
        setmetatable(parse, parse_mt)
        local good, ast_elem = pcall(custom_handlers[elem.type], elem, parse)
        if good and (not ast_elem or not ast_elem.type) then
            good, ast_elem = false, "Function didn't return AST element!"
        end
        if good then
            return ast_elem, true
        else
            return nil, 'Invalid element "' .. raw_unparse({elem}) .. '": ' ..
                tostring(ast_elem)
        end
    end

    local good, ast_elem
    for _, template in ipairs(data) do
        local custom_element = type(template) == 'function'
        if custom_element then
            good, ast_elem = pcall(template, elem)
            if good and (not ast_elem or not ast_elem.type) then
                good, ast_elem = false, "Function didn't return AST element!"
            end
        else
            good, ast_elem = pcall(parse_value, elem, template)
        end
        if good then
            return ast_elem, custom_element
        end
    end

    return nil, 'Invalid element "' .. raw_unparse({elem}) .. '": ' ..
        tostring(ast_elem)
end

-- Parse a formspec into a formspec AST.
-- Input: size[5,2] style[name;bgcolor=blue;textcolor=yellow]
--            button[0,0;5,1;name;Label] image[0,1;1,1;air.png]
-- Output:
-- {
--     formspec_version = 1,
--     {
--         type = "size",
--         w = 5,
--         h = 2,
--     },
--     {
--         type = "style",
--         name = "name",
--         props = {
--             bgcolor = "blue",
--             textcolor = "yellow",
--         },
--     },
--     {
--         type = "button",
--         x = 0,
--         y = 0,
--         w = 5,
--         h = 1,
--         name = "name",
--         label = "Label",
--     },
--     {
--         type = "image",
--         x = 0,
--         y = 1,
--         w = 1,
--         h = 1,
--         texture_name = "air.png",
--     }
-- }


function formspec_ast.parse(fs, custom_handlers)
    local spec = raw_parse(fs)
    local res = {formspec_version=1}
    local containers = {}
    local container = res
    for _, elem in ipairs(spec) do
        local ast_elem, err = parse_elem(elem, custom_handlers)
        if not ast_elem then
            return nil, err
        end
        table.insert(container, ast_elem)
        if (ast_elem.type == 'container' or
                ast_elem.type == 'scroll_container') and not err then
            table.insert(containers, container)
            container = ast_elem
        elseif ast_elem.type == 'end' or ast_elem.type == 'container_end' or
                ast_elem.type == 'scroll_container_end' then
            container[#container] = nil
            container = table.remove(containers)
            if not container then
                return nil, 'Mismatched container_end[]!'
            end
        end
    end

    if res[1] and res[1].type == 'formspec_version' then
        res.formspec_version = table.remove(res, 1).version
    end
    return res
end

-- Unparsing
local compat_keys = {listelems = "listelem", items = "item",
    captions = "caption"}
local function unparse_ellipsis(elem, obj1, res, inner)
    if obj1[2] == 'table' then
        local value = elem[obj1[1]]
        assert(type(value) == 'table', 'Invalid AST!')
        for k, v in pairs(value) do
            table.insert(res, tostring(k) .. '=' .. tostring(v))
        end
    elseif type(obj1[2]) == 'string' then
        local value = elem[obj1[1]]
        if value == nil then
            value = elem[compat_keys[obj1[1]]]
            if value == nil then return end
        end
        for _, v in ipairs(value) do
            table.insert(res, tostring(v))
        end
    else
        assert(inner == nil)
        local data = elem[elem.type or 'data'] or elem
        for _, elem2 in ipairs(data) do
            local r = {}
            for _, obj2 in ipairs(obj1) do
                if obj2[2] == '...' then
                    unparse_ellipsis(elem2, obj2[1], r, true)
                elseif type(obj2[2]) == 'string' then
                    table.insert(r, tostring(elem2[obj2[1]]))
                end
            end
            table.insert(res, r)
        end
    end
end

local function unparse_value(elem, template)
    local res = {}
    for i, obj in ipairs(template) do
        if obj[2] == '...' then
            assert(template[i + 1] == nil, 'Invalid template!')
            unparse_ellipsis(elem, obj[1], res)
        elseif type(obj[2]) == 'string' then
            local value = elem[obj[1]]
            if value == nil then
                res[i] = ''
            else
                res[i] = tostring(value)
            end
        else
            res[i] = unparse_value(elem, obj)
        end
    end
    return res
end

local compare_blanks
do
    local function get_nonempty(a)
        if a.nonempty then
            return a.nonempty, a.strings, a.total_length
        end
        local nonempty, strings, total_length = 0, 0, #a
        for _, i in ipairs(a) do
            if type(i) == 'string' and i ~= '' then
                nonempty = nonempty + 1
                strings = strings + 1
            elseif type(i) == 'table' then
                local n, s, t = get_nonempty(i)
                nonempty = nonempty + n
                strings = strings + s
                total_length = total_length + t
            end
        end
        a.nonempty, a.strings, a.total_length = nonempty, strings, total_length
        return nonempty, strings, total_length
    end

    function compare_blanks(a, b)
        local a_n, a_strings, a_l = get_nonempty(a)
        local b_n, b_strings, b_l = get_nonempty(b)
        if a_n == b_n then
            if a_l == b_l then
                -- Prefer elements with less tables
                return a_strings > b_strings
            else
                return a_l < b_l
            end
        end
        return a_n >= b_n
    end
end

local function unparse_elem(elem, res, force)
    if (elem.type == 'container' or
            elem.type == 'scroll_container') and not force then
        local err = unparse_elem(elem, res, true)
        if err then return err end
        for _, e in ipairs(elem) do
            err = unparse_elem(e, res)
            if err then return err end
        end
        return unparse_elem({type=elem.type .. '_end'}, res, true)
    end

    local data = elements[elem.type]
    if not data or (not force and elem.type == 'container_end') then
        return nil, 'Unknown element "' .. tostring(elem.type) .. '".'
    end

    local good, raw_elem
    local possible_elems = {}
    for _, template in ipairs(data) do
        if type(template) == 'function' then
            good, raw_elem = false, 'Unknown element.'
        else
            good, raw_elem = pcall(unparse_value, elem, template)
        end
        if good then
            raw_elem.type = elem.type
            table.insert(possible_elems, raw_elem)
        end
    end

    -- Use the shortest element format that doesn't lose any information.
    if good then
        table.sort(possible_elems, compare_blanks)
        table.insert(res, possible_elems[1])
    else
        return 'Invalid element with type "' .. tostring(elem.type)
            .. '": ' .. tostring(raw_elem)
    end
end

-- Convert a formspec AST back into a formspec.
-- Input:
-- {
--     {
--         type = "size",
--         w = 5,
--         h = 2,
--     },
--     {
--         type = "button",
--         x = 0,
--         y = 0,
--         w = 5,
--         h = 1,
--         name = "name",
--         label = "Label",
--     },
--     {
--         type = "image",
--         x = 0,
--         y = 1,
--         w = 1,
--         h = 1,
--         texture_name = "air.png",
--     }
-- }
-- Output: size[5,2]button[0,0;5,1;name;Label]image[0,1;1,1;air.png]
function formspec_ast.unparse(tree)
    local raw_spec = {}
    if tree.formspec_version and tree.formspec_version ~= 1 then
        raw_spec[1] = {
            type = 'formspec_version',
            tostring(tree.formspec_version)
        }
    end

    for _, elem in ipairs(tree) do
        local err = unparse_elem(elem, raw_spec)
        if err then
            return nil, err
        end
    end
    return raw_unparse(raw_spec)
end

-- Allow other mods to access raw_parse and raw_unparse. Note that these may
-- change or be removed at any time.
-- formspec_ast._raw_parse = raw_parse
-- formspec_ast._raw_unparse = raw_unparse

-- Register custom elements
parse_mt = {}
function parse_mt:__index(key)
    if key == '...' then
        key = nil
    end

    local func = types[key]
    if func then
        return function(obj)
            if type(obj) == 'table' then
                obj = table_concat(obj, ',')
            end
            return func(obj or '')
        end
    else
        return function(_)
            error('Unknown element type: ' .. tostring(key))
        end
    end
end

-- Register custom formspec elements.
-- `parse_func` gets two parameters: `raw_elem` and `parse`. The parse table
-- is the same as the types table above, however unknown types raise an error.
-- The function should return either a single AST node or a list of multiple
-- nodes.
-- Multiple functions can be registered for one element.
-- This API should not be used outside of formspec_ast.
function formspec_ast.register_element(name, parse_func)
    assert(type(name) == 'string' and type(parse_func) == 'function')
    if not elements[name] then
        elements[name] = {}
    end
    local parse = {}
    setmetatable(parse, parse_mt)
    table.insert(elements[name], function(raw_elem)
        local res = parse_func(raw_elem, parse)
        if type(res) == 'table' and not res.type then
            res.type = 'container'
            res.x, res.y = 0, 0
        end
        return res
    end)
end
