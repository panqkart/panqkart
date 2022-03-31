--
-- formspec_ast: An abstract system tree for formspecs.
--
-- This does not actually depend on Minetest and could probably run in
-- standalone Lua.
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

local formspec_ast, minetest = formspec_ast, formspec_ast.minetest

-- Parse a formspec into a "raw" non-AST state.
-- Input: size[5,2]button[0,0;5,1;name;Label] image[0,1;1,1;air.png]
-- Output: {{'size', '5', '2'}, {'button', '0,0', '5,1', 'name', 'label'},
--             {'image', '0,1', '1,1', 'air.png'}}
local function raw_parse(spec)
    local res = {}
    while spec do
        -- Get the first element
        local name
        name, spec = spec:match('([%w_%-:]*[^%s\\])%s*(%[.*)')
        if not name or not spec then return res end
        local elem = {}
        elem[1] = name

        -- Get the parameters
        local s, e = spec:find('[^\\]%]')
        local rawargs
        if s and e then
            rawargs, spec = spec:sub(2, s), spec:sub(e + 1)
        else
            rawargs, spec = spec:sub(2), false
        end

        -- Split everything
        -- TODO: Make this a RegEx
        local i = ''
        local esc = false
        local inner = {}
        for c = 1, #rawargs do
            local char = rawargs:sub(c, c)
            if esc then
                esc = false
                i = i .. char
            elseif char == '\\' then
                    esc = true
            elseif char == ';' then
                if #inner > 0 then
                    table.insert(inner, i)
                    table.insert(elem, inner)
                    inner = {}
                else
                    table.insert(elem, i)
                end
                i = ''
            elseif char == ',' then
                table.insert(inner, i)
                i = ''
            else
                i = i .. char
            end
        end
        if #inner > 0 then
            table.insert(inner, i)
            table.insert(elem, inner)
            inner = {}
        else
            table.insert(elem, i)
        end

        table.insert(res, elem)
    end

    return res
end

-- Unparse raw formspecs
-- WARNING: This will modify the table passed to it.
local function raw_unparse(data)
    local res = ''
    for _, elem in ipairs(data) do
        for i = 2, #elem do
            if type(elem[i]) == 'table' then
                for j, e in ipairs(elem[i]) do
                    elem[i][j] = minetest.formspec_escape(e)
                end
                elem[i] = table.concat(elem[i], ',')
            else
                elem[i] = minetest.formspec_escape(elem[i])
            end
        end
        res = res .. table.remove(elem, 1) .. '[' ..
            table.concat(elem, ';') .. ']'
    end
    return res
end

-- Elements
-- The element format is currently not intuitive.
local elements = assert(loadfile(formspec_ast.modpath .. '/elements.lua'))()

-- Parsing
local types = {}

function types.null() end
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

function types.table(obj)
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
                elem = table.concat(elem, ',')
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
    for i, elem in ipairs(elems) do
        local n = parse_value({elem}, template)
        if is_string then
            n = n[obj[1]]
        end
        table.insert(val, n)
    end

    if obj[2] == 'table' then
        local t = {}
        for _, n in ipairs(val) do
            local k, v = next(n)
            t[k] = v
        end
        res[obj[1] .. 's'] = t
    elseif type(obj[2]) == 'string' then
        res[obj[1]] = val
    else
        assert(type(val) == 'table')
        res[res.type or 'data'] = val
    end
end

local parse_mt
local function parse_elem(elem, custom_handlers)
    elem.type = table.remove(elem, 1)
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
            return ast_elem
        else
            table.insert(elem, 1, elem.type)
            return nil, 'Invalid element "' .. raw_unparse({elem}) .. '": ' ..
                tostring(ast_elem)
        end
    end

    local good, ast_elem
    for i, template in ipairs(data) do
        if type(template) == 'function' then
            good, ast_elem = pcall(template, elem)
            if good and (not ast_elem or not ast_elem.type) then
                good, ast_elem = false, "Function didn't return AST element!"
            end
        else
            good, ast_elem = pcall(parse_value, elem, template)
        end
        if good then
            return ast_elem
        end
    end

    table.insert(elem, 1, elem.type)
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


function formspec_ast.parse(spec, custom_handlers)
    spec = raw_parse(spec)
    local res = {formspec_version=1}
    local containers = {}
    local container = res
    for _, elem in ipairs(spec) do
        local ast_elem, err = parse_elem(elem, custom_handlers)
        if not ast_elem then
            return nil, err
        end
        table.insert(container, ast_elem)
        if ast_elem.type == 'container' or
                ast_elem.type == 'scroll_container' then
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
local function unparse_ellipsis(elem, obj1, res, inner)
    if obj1[2] == 'table' then
        local value = elem[obj1[1] .. 's']
        assert(type(value) == 'table', 'Invalid AST!')
        for k, v in pairs(value) do
            table.insert(res, tostring(k) .. '=' .. tostring(v))
        end
    elseif type(obj1[2]) == 'string' then
        local value = elem[obj1[1]]
        if value == nil then return end
        for k, v in ipairs(value) do
            table.insert(res, tostring(v))
        end
    else
        assert(inner == nil)
        local data = elem[elem.type or 'data'] or elem
        for _, elem2 in ipairs(data) do
            local r = {}
            for i, obj2 in ipairs(obj1) do
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
        local nonempty = 0
        for _, i in ipairs(a) do
            if type(i) == 'string' and i ~= '' then
                nonempty = nonempty + 1
            elseif type(i) == 'table' then
                nonempty = nonempty + get_nonempty(i)
            end
        end
        a.nonempty = nonempty
        return nonempty
    end

    function compare_blanks(a, b)
        local a_n, b_n = get_nonempty(a), get_nonempty(b)
        if a_n == b_n then
            return #a < #b
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
            local err = unparse_elem(e, res)
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
    for i, template in ipairs(data) do
        if type(template) == 'function' then
            good, raw_elem = false, 'Unknown element.'
        else
            good, raw_elem = pcall(unparse_value, elem, template)
        end
        if good then
            table.insert(raw_elem, 1, elem.type)
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
-- Output: size[5,2,]button[0,0;5,1;name;Label]image[0,1;1,1;air.png]
function formspec_ast.unparse(spec)
    local raw_spec = {}
    for _, elem in ipairs(spec) do
        local err = unparse_elem(elem, raw_spec)
        if err then
            return nil, err
        end
    end

    if spec.formspec_version and spec.formspec_version ~= 1 then
        table.insert(raw_spec, 1, {'formspec_version',
                                   tostring(spec.formspec_version)})
    end
    return raw_unparse(raw_spec)
end

-- Allow other mods to access raw_parse and raw_unparse. Note that these may
-- change or be removed at any time.
formspec_ast._raw_parse = raw_parse
formspec_ast._raw_unparse = raw_unparse

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
                obj = table.concat(obj, ',')
            end
            return func(obj or '')
        end
    else
        return function(obj)
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
