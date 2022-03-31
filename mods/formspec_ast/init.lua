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

formspec_ast = {}

local modpath

if minetest then
    -- Running inside Minetest.
    formspec_ast.minetest = minetest
    modpath = minetest.get_modpath('formspec_ast')
    assert(minetest.get_current_modname() == 'formspec_ast',
           'This mod must be called formspec_ast!')
    formspec_ast.formspec_escape = minetest.formspec_escape
else
    -- Probably running outside Minetest.
    modpath = rawget(_G, 'FORMSPEC_AST_PATH') or '.'
    local minetest = {}
    function minetest.is_yes(str)
        str = str:lower()
        return str == 'true' or str == 'yes'
    end
    function minetest.formspec_escape(text)
        if text then
            for _, n in ipairs({'\\', ']', '[', ';', ','}) do
                text = text:gsub('%' .. n, '\\' .. n)
            end
        end
        return text
    end
    minetest.log = print
    function string.trim(str)
        return str:gsub("^%s*(.-)%s*$", "%1")
    end
    -- Mostly copied from https://stackoverflow.com/a/26367080
    function table.copy(obj, s)
        if type(obj) ~= 'table' then return obj end
        if s and s[obj] ~= nil then return s[obj] end
        s = s or {}
        local res = {}
        s[obj] = res
        for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
        return res
    end
    formspec_ast.minetest = minetest
    formspec_ast.formspec_escape = minetest.formspec_escape
end

formspec_ast.modpath = modpath

dofile(modpath .. '/core.lua')
dofile(modpath .. '/helpers.lua')
dofile(modpath .. '/safety.lua')

formspec_ast.modpath, formspec_ast.minetest = nil, nil
