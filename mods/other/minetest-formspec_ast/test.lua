dofile('init.lua')

-- luacheck: read_globals assert it describe

local function test_parse(fs, expected_tree)
    -- Make single elements lists and add formspec_version
    if expected_tree.type then
        expected_tree = {expected_tree}
    end
    if not expected_tree.formspec_version then
        expected_tree.formspec_version = 1
    end

    local tree = assert(formspec_ast.parse(fs))
    assert.same(tree, expected_tree)
end

local function test_parse_unparse(fs, expected_tree)
    test_parse(fs, expected_tree)
    local unparsed_fs = assert(formspec_ast.unparse(expected_tree))
    assert.equals(fs, unparsed_fs)
end

it("can parse complex escapes", function()
    test_parse_unparse([=[label[123,456;yay abc def\, ghi\; jkl mno \]\\]]=], {
        formspec_version = 1,
        {
            type = 'label',
            x = 123,
            y = 456,
            label = 'yay abc def, ghi; jkl mno ]\\'
        }
    })
end)

it("can round-trip most elements", function()
    local fs = [[
        formspec_version[2]
        size[5,2]
        padding[1,2]
        no_prepend[]
        container[1,1]
            label[0,0;Containers are fun\]\\]
            container[-1,-1]
                button[0.5,0;4,1;name;Label]
            container_end[]
            label[0,1;Nested containers work too.]
            scroll_container[0,2;1,1;scrollbar;vertical]
                button[0.5,0;4,1;name;Label]
            scroll_container_end[]
        container_end[]
        image[0,1;1,1;air.png]
        set_focus[name;true]
        dropdown[0,0;1;test;abc,def,ghi,jkl;2]
        dropdown[0,0;1;test;abc,def,ghi,jkl;2;true]
        field_close_on_enter[my-field;false]
        bgcolor[blue]
        bgcolor[blue;true]
        bgcolor[blue;both;green]
        tooltip[1,2;3,4;text]
        tooltip[elem;text;bgcolor]
        background9[1,2;3,4;bg.png;false;5]
        background9[1,2;3,4;bg.png;false;5,6]
        background9[1,2;3,4;bg.png;false;5,6,7,8]
        tablecolumns[text;image;color,option=value;tree]
        list[test;test2;1,2;3,4;5]
        list[test6;test7;8,9;10,11]
        image_button[1,2;3,4;img.png;name;label]
        image_button[1,2;3,4;img.png;name;label;false;true]
        image_button[1,2;3,4;img.png;name;label;true;false;img2.png]
        image_button_exit[1,2;3,4;img.png;name;label]
        image_button_exit[1,2;3,4;img.png;name;label;false;true]
        image_button_exit[1,2;3,4;img.png;name;label;true;false;img2.png]
        image[1,2;3,4;air.png;5]
        image[1,2;3,4;air.png;5,6]
        image[1,2;3,4;air.png;5,6,7,8]
        field_enter_after_edit[test;true]
    ]]
    fs = ('\n' .. fs):gsub('\n[ \n]*', '')

    test_parse_unparse(fs, {
        formspec_version = 2,
        {
            type = "size",
            w = 5,
            h = 2,
        },
        {
            type = "padding",
            x = 1,
            y = 2,
        },
        {
            type = "no_prepend"
        },
        {
            type = "container",
            x = 1,
            y = 1,
            {
                type = "label",
                x = 0,
                y = 0,
                label = "Containers are fun]\\",
            },
            {
                type = "container",
                x = -1,
                y = -1,
                {
                    type = "button",
                    x = 0.5,
                    y = 0,
                    w = 4,
                    h = 1,
                    name = "name",
                    label = "Label",
                },
            },
            {
                type = "label",
                x = 0,
                y = 1,
                label = "Nested containers work too.",
            },
            {
                type = "scroll_container",
                x = 0,
                y = 2,
                w = 1,
                h = 1,
                scrollbar_name = "scrollbar",
                orientation = "vertical",
                -- scroll_factor = nil,
                {
                    h = 1,
                    y = 0,
                    label = "Label",
                    w = 4,
                    name = "name",
                    x = 0.5,
                    type = "button"
                },
            },
        },
        {
            type = "image",
            x = 0,
            y = 1,
            w = 1,
            h = 1,
            texture_name = "air.png",
        },
        {
            type = "set_focus",
            name = "name",
            force = true,
        },
        {
            type = "dropdown",
            x = 0,
            y = 0,
            w = 1,
            name = "test",
            items = {"abc", "def", "ghi", "jkl"},
            selected_idx = 2,
        },
        {
            type = "dropdown",
            x = 0,
            y = 0,
            w = 1,
            name = "test",
            items = {"abc", "def", "ghi", "jkl"},
            selected_idx = 2,
            index_event = true,
        },
        {
            type = "field_close_on_enter",
            name = "my-field",
            close_on_enter = false,
        },
        {
            type = "bgcolor",
            bgcolor = "blue",
        },
        {
            type = "bgcolor",
            bgcolor = "blue",
            fullscreen = true,
        },
        {
            type = "bgcolor",
            bgcolor = "blue",
            fullscreen = "both",
            fbgcolor = "green",
        },
        {
            type = "tooltip",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            tooltip_text = "text",
        },
        {
            type = "tooltip",
            gui_element_name = "elem",
            tooltip_text = "text",
            bgcolor = "bgcolor",
        },
        {
            type = "background9",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "bg.png",
            auto_clip = false,
            middle_x = 5,
        },
        {
            type = "background9",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "bg.png",
            auto_clip = false,
            middle_x = 5,
            middle_y = 6,
        },
        {
            type = "background9",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "bg.png",
            auto_clip = false,
            middle_x = 5,
            middle_y = 6,
            middle_x2 = 7,
            middle_y2 = 8,
        },
        {
            type = "tablecolumns",
            tablecolumns = {
                {type = "text", opts = {}},
                {type = "image", opts = {}},
                {type = "color", opts = {option = "value"}},
                {type = "tree", opts = {}},
            },
        },
        {
            type = "list",
            inventory_location = "test",
            list_name = "test2",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            starting_item_index = 5,
        },
        {
            type = "list",
            inventory_location = "test6",
            list_name = "test7",
            x = 8,
            y = 9,
            w = 10,
            h = 11,
        },
        {
            type = "image_button",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
        },
        {
            type = "image_button",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
            noclip = false,
            drawborder = true,
        },
        {
            type = "image_button",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
            noclip = true,
            drawborder = false,
            pressed_texture_name = "img2.png",
        },
        {
            type = "image_button_exit",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
        },
        {
            type = "image_button_exit",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
            noclip = false,
            drawborder = true,
        },
        {
            type = "image_button_exit",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "img.png",
            name = "name",
            label = "label",
            noclip = true,
            drawborder = false,
            pressed_texture_name = "img2.png",
        },
        {
            type = "image",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "air.png",
            middle_x = 5,
        },
        {
            type = "image",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "air.png",
            middle_x = 5,
            middle_y = 6,
        },
        {
            type = "image",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            texture_name = "air.png",
            middle_x = 5,
            middle_y = 6,
            middle_x2 = 7,
            middle_y2 = 8,
        },
        {
            type = "field_enter_after_edit",
            name = "test",
            enter_after_edit = true,
        },
    })
end)

local function remove_trailing_params(elem_s, elem, ...)
    local res = {}
    local strings = {}
    local optional_params = {...}
    for i = #optional_params, 1, -1 do
        local p = optional_params[i]
        local no_copy = {}
        if type(p) == "table" then
            for _, param in ipairs(p) do
                no_copy[param] = true
            end
        else
            no_copy[p] = true
        end

        res[i] = elem
        strings[i] = elem_s
        elem_s = elem_s:gsub(";[^;]+%]$", "]")
        local old_elem = elem
        elem = {}
        for k, v in pairs(old_elem) do
            if not no_copy[k] then
                elem[k] = v
            end
        end
    end
    return table.concat(strings, ""), res
end

it("can parse model[]", function()
    test_parse_unparse(remove_trailing_params(
        "model[1,2;3,4;abc;def;ghi,jkl;5,6;true;false;7,8;9]",
        {
            type = "model",
            x = 1,
            y = 2,
            w = 3,
            h = 4,
            name = "abc",
            mesh = "def",
            textures = {"ghi", "jkl"},
            rotation_x = 5,
            rotation_y = 6,
            continuous = true,
            mouse_control = false,
            frame_loop_begin = 7,
            frame_loop_end = 8,
            animation_speed = 9
        },
        {"rotation_x", "rotation_y"}, "continuous", "mouse_control",
        {"frame_loop_begin", "frame_loop_end"}, "animation_speed"
    ))
end)

it("can round-trip style[]", function()
    local s = 'style[test1,test2;def=ghi]style_type[test;abc=def]'
    assert.equals(s, assert(formspec_ast.interpret(s)))
    test_parse('style[name,name2;bgcolor=blue;textcolor=yellow]', {
        type = "style",
        selectors = {
            "name",
            "name2",
        },
        props = {
            bgcolor = "blue",
            textcolor = "yellow",
        },
    })
end)

-- Test item/items compatibility
it("can parse dropdown[]", function()
    local expected = 'dropdown[0,0;1,2;test;abc,def,ghi,jkl;2;true]'
    assert.equals(
        expected,
        assert(formspec_ast.unparse({
            {
                type = "dropdown",
                x = 0,
                y = 0,
                w = 1,
                h = 2,
                name = "test",
                items = {"abc", "def", "ghi", "jkl"},
                selected_idx = 2,
                index_event = true,
            },
        }))
    )
    assert.equals(
        expected,
        assert(formspec_ast.unparse({
            {
                type = "dropdown",
                x = 0,
                y = 0,
                w = 1,
                h = 2,
                name = "test",
                item = {"abc", "def", "ghi", "jkl"},
                selected_idx = 2,
                index_event = true,
            },
        }))
    )
end)

-- Ensure the style[] unparse compatibility works correctly
it("can unparse style with name", function()
    local expected = 'style_type[test;abc=def]'
    assert.equals(
        expected,
        assert(formspec_ast.unparse({
            {
                type = 'style_type',
                name = 'test',
                props = {
                    abc = 'def',
                },
            }
        }))
    )
    assert.equals(
        expected,
        assert(formspec_ast.unparse({
            {
                type = 'style_type',
                selectors = {
                    'test',
                },
                props = {
                    abc = 'def',
                },
            }
        }))
    )
end)

-- Ensure flatten works correctly
it("flattens formspecs correctly", function()
    assert.equals(
        'label[0,0;abc]label[2,2;def]scroll_container[1,1;2,2;test;vertical]' ..
            'image[1,1;1,1;def]scroll_container_end[]',
        formspec_ast.unparse(formspec_ast.flatten(assert(formspec_ast.parse([[
            label[0,0;abc]
            container[3,2]
                container[-1,0]
                    label[0,0;def]
                container_end[]
            container_end[]
            scroll_container[1,1;2,2;test;vertical]
                image[1,1;1,1;def]
            scroll_container_end[]
        ]]))))
    )
end)

it("interprets invsize[] and escapes correctly", function()
    assert.equals(assert(formspec_ast.interpret('invsize[12,34]')),
        'size[12,34]')

    assert.equals(assert(formspec_ast.interpret('label[1,2;abc\\')),
        'label[1,2;abc]')
    assert.equals(assert(formspec_ast.interpret('label[1,2;abc\\\\')),
        'label[1,2;abc\\\\]')

    assert.equals(formspec_ast.formspec_escape('label[1,2;abc\\def]'),
        'label\\[1\\,2\\;abc\\\\def\\]')
end)

it("safe_interpret", function()
    assert.equals(
        formspec_ast.safe_interpret([[
            formspec_version[5.1]
            size[3,3]
            label[0,0;Hi]
            image[1,2;3,4;a^b\[c]
            formspec_ast:crash[]
            textlist[1,2;3,4;test;a,b,c]
        ]]),
        'formspec_version[5]size[3,3]label[0,0;Hi]image[1,2;3,4;a^b]' ..
            'textlist[1,2;3,4;test;a,b,c]'
    )
end)

it("can parse tabheader", function()
    local fs =
        "tabheader[1,2;name;a,b,c;1]" ..
        "tabheader[1,2;name;a,b,c;1;false;true]" ..

        -- Width and height can only be specified if transparent and drawborder
        -- are specified
        "tabheader[1,2;3,4;name;a,b,c;1;false;true]" ..
        "tabheader[1,2;3;name;a,b,c;1;false;true]" ..
        "tabheader[1,2;3;name;a,b,c;1;;]"

    test_parse_unparse(fs, {
        {
            type = "tabheader",
            x = 1, y = 2,
            name = "name",
            captions = {"a", "b", "c"},
            current_tab = 1
        },
        {
            type = "tabheader",
            x = 1, y = 2,
            name = "name",
            captions = {"a", "b", "c"},
            current_tab = 1,
            transparent = false,
            draw_border = true
        },
        {
            type = "tabheader",
            x = 1, y = 2, w = 3, h = 4,
            name = "name",
            captions = {"a", "b", "c"},
            current_tab = 1,
            transparent = false,
            draw_border = true
        },
        {
            type = "tabheader",
            x = 1, y = 2, h = 3,
            name = "name",
            captions = {"a", "b", "c"},
            current_tab = 1,
            transparent = false,
            draw_border = true
        },
        {
            type = "tabheader",
            x = 1, y = 2, h = 3,
            name = "name",
            captions = {"a", "b", "c"},
            current_tab = 1,
        },
    })
end)

it("does not parse invalid tabheader elements", function()
    assert.is_nil(formspec_ast.parse("tabheader[1,2;name;a,b,c]"))
    assert.is_nil(formspec_ast.parse("tabheader[1,2;name;a,b,c;1;false]"))
    assert.is_nil(formspec_ast.parse("tabheader[1,2;3,4;name;a,b,c;1]"))
end)

describe("helpers", function ()
    describe("walk", function ()
        it("walks over every element", function ()
            local tree = {
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "container",
                    { type = "label", label = "the text" }
                }
            }
            for node in formspec_ast.walk(tree) do
                node.visited = true
            end
            assert.same({
                { type = "box", color = "green", visited = true },
                { type = "label", label = "the text", visited = true },
                {
                    type = "container",
                    visited = true,
                    { type = "label", label = "the text", visited = true }
                }
            }, tree)
        end)
        it("can be stopped", function ()
                local tree = {
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "container",
                    { type = "label", label = "the text" }
                },
                { type = "label", label = "the text" }
            }
            local count = 0
            for node in formspec_ast.walk(tree) do
                count = count + 1
                node.visited = true
                if count == 3 then break end
            end
            assert.same({
                { type = "box", color = "green", visited = true },
                { type = "label", label = "the text", visited = true },
                {
                    type = "container",
                    visited = true,
                    { type = "label", label = "the text" }
                },
                { type = "label", label = "the text" }
            }, tree)
        end)
        it("can accept custom element list", function ()
            local tree = {
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "nonsensewordhere",
                    { type = "label", label = "the text" }
                },
                {
                    type = "container",
                    { type = "label", label = "the text" }
                },
                { type = "label", label = "the text" }
            }
            for node in formspec_ast.walk(tree, {nonsensewordhere = true}) do
                node.visited = true
            end
            assert.same({
                { type = "box", color = "green", visited = true },
                { type = "label", label = "the text", visited = true },
                {
                    type = "nonsensewordhere",
                    visited = true,
                    { type = "label", label = "the text", visited = true }
                },
                {
                    type = "container",
                    visited = true,
                    { type = "label", label = "the text" }
                },
                { type = "label", label = "the text", visited = true }
            }, tree)
        end)
        it("can provide parent info when walking", function ()
            local tree = {
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "container",
                    { type = "label", label = "the text" }
                },
                { type = "label", label = "the text" }
            }
            local logged_indexes = {}
            for node, parent, index in formspec_ast.walk(tree) do
                node.visited = true
                parent.parent_of = (parent.parent_of or 0) + 1
                logged_indexes[#logged_indexes+1] = index
            end
            assert.same({
                parent_of = 4,
                { type = "box", color = "green", visited = true },
                { type = "label", label = "the text", visited = true },
                {
                    type = "container",
                    visited = true,
                    parent_of = 1,
                    { type = "label", label = "the text", visited = true }
                },
                { type = "label", label = "the text", visited = true },
            }, tree)
            -- NOTE: this is, in effect, asserting the order of the crawl
            assert.same({ 1, 2, 3, 1, 4}, logged_indexes)
        end)
        it("parent info can be modified without failure", function ()
            -- INFO: This test is a regression test.
            local tree = {
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "container",
                    { type = "label", label = "the text" }
                }
            }
            local found_child = false
            for node, parent in formspec_ast.walk(tree) do
                if node.type == "container" then
                    node[#node+1] = { type = "label", label = "the new text" }
                elseif parent.type == "container" then
                    node.is_child_thingy = true
                    if not found_child then
                        found_child = true
                        node.type = "container"
                        node[1] = { type = "box", color = "red" }
                        node.label = nil
                    end
                end
            end
            assert.same({
                { type = "box", color = "green" },
                { type = "label", label = "the text" },
                {
                    type = "container",
                    {
                        type = "container",
                        is_child_thingy = true,
                        { type = "box", color = "red", is_child_thingy = true }
                    },
                    {
                        type = "label",
                        label = "the new text",
                        is_child_thingy = true
                    }
                }
            }, tree)
        end)
    end)
end)
