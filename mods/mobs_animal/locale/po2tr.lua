#!/usr/bin/env luajit

-- Convert regular Gettext PO files to Minetest-specific TR files. If there is
-- already a TR file with the same name of the PO file except the file suffix
-- bneing .tr (or .TR) instead of .po (or .PO) then THIS FILE WILL BE
-- OVERWRITTEN WITHOUT INFORMATION OR A WAY TO RECOVER THE PREVIOUS FILE!
--
--
--                                 ▄██▄
--                                 ▀███
--                                    █
--                   ▄▄▄▄▄            █
--                  ▀▄    ▀▄          █              BACKUP
--              ▄▀▀▀▄ █▄▄▄▄█▄▄ ▄▀▀▀▄  █
--             █  ▄  █        █   ▄ █ █
--             ▀▄   ▄▀        ▀▄   ▄▀ █
--              █▀▀▀            ▀▀▀ █ █
--              █                   █ █        ALL
--    ▄▀▄▄▀▄    █  ▄█▀█▀█▀█▀█▀█▄    █ █
--    █▒▒▒▒█    █  █████████████▄   █ █     
--    █▒▒▒▒█    █  ██████████████▄  █ █
--    █▒▒▒▒█    █   ██████████████▄ █ █
--    █▒▒▒▒█    █    ██████████████ █ █
--    █▒▒▒▒█    █   ██████████████▀ █ █           THE
--    █▒▒▒▒█   ██   ██████████████  █ █
--    ▀████▀  ██▀█  █████████████▀  █▄█
--      ██   ██  ▀█  █▄█▄█▄█▄█▄█▀  ▄█▀
--      ██  ██    ▀█             ▄▀▓█
--      ██ ██      ▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█
--      ████        █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
--      ███         █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█                 THINGS
--      ██          █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
--      ██          █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
--      ██         ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
--      ██        ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
--      ██       ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌           !!!
--      ██      ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌
--      ██     ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌
--      ██    ▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌
--
--
-- The syntax of TR files according to the introducing forum post is:
--
-- # textdomain: namespace
-- original 1 = translation 1
-- original 2 = translation 2
-- original 3 = tralslation 3
-- original N = translation N
--
-- Where namespace should be the name of the mod. Following strings have to be
-- escaped using @.
--
-- String | Escape 
-- -------+--------
-- `@`    |`@@`
-- `=`    |`@=`
-- `\n`   |`@\n`
--
-- See https://forum.minetest.net/viewtopic.php?t=18349 for details.


-- Preparation
if arg[1] == nil or arg[2] == nil then
    print('Provide the namesspace as first parameter')
    print('Provide the path to the source PO file as second parameter')
    print('Example: '..arg[0]..' mymod path/to/my/source.po')
    return
end
local SEP = package.path:match('(%p)%?%.') or '/' -- wonky but hey ... :)


-- Assign parameters to local variables
local namespace = arg[1]
local po_file = arg[2]
local tr_file = arg[2]:gsub('po$', 'tr'):gsub('PO$', 'TR')


-- Get the translations through crude plaintext file parsing
local file_contents = {}
local translations = {}

local po_file_handle = io.open(po_file, 'rb')
if po_file_handle == nil then print('No base file found') return end

for line in po_file_handle:lines() do
    if line:match('^msgid') or line:match('^msgstr') then
        table.insert(file_contents, line)
    end
end

local escape_string = function (s)
    s = s:gsub('@([^%d])', '@@%1') -- All @ not followed by a number become @@
    s = s:gsub('([^@]@)$', '%1@')  -- An @ at the end of the string become @@
    s = s:gsub('=', '@=')          -- All = become @=
    return s
end

for number,line_content in pairs(file_contents) do
    if line_content:match('^msgid') then
        local o = line_content:gsub('^msgid "(.+)"$', '%1')
        local t = file_contents[number + 1]:gsub('^msgstr "(.+)"$', '%1')
        if o ~= 'msgid = ""' and t ~= 'msgstr ""' then
            table.insert(translations, escape_string(o)..'='..escape_string(t))
        end
    end
end
print(number)
po_file_handle:close()


-- Write translation to file
local tr_file_handle = io.open(tr_file, 'w+')
if tr_file_handle == nil then print('Could not open target file') return end
tr_file_handle:write('# textdomain: '..namespace, "\n")
for _,line in pairs(translations) do tr_file_handle:write(line, "\n") end
tr_file_handle:close()
