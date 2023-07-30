# formspec_ast

A Minetest mod library to make modifying formspecs easier.

## API

 - `formspec_ast.parse(formspec_string)`: Parses `formspec_string` and returns
    an AST.
 - `formspec_ast.unparse(tree)`: Unparses the abstract syntax tree provided
    and returns a formspec string.
 - `formspec_ast.interpret(string_or_tree)`: Returns a formspec string after
    (optionally parsing) and unparsing the formspec provided.
 - `formspec_ast.walk(tree, optional_container_set)`: Returns an iterator (use this directly in a for
    loop) that will return all nodes in a tree, including ones inside
    containers. The containers are recognised by `type`, and can be overriden
    with a table of `name` to `true` relationships in `optional_container_set`
 - `formspec_ast.find(tree, node_type)`: Similar to `walk(tree)`, however only
    returns `node_type` nodes.
 - `formspec_ast.get_element_by_name(tree, name)`: Returns the first element in
    the tree with the name `name`.
 - `formspec_ast.get_elements_by_name(tree, name)`: Returns a list of all the
    elements with the name `name`.
 - `formspec_ast.apply_offset(tree, x, y)`: Shifts all elements in `tree`.
    Similar to `container`.
 - `formspec_ast.flatten(tree)`: Removes all containers and offsets elements
    that were in containers accordingly. Note that `scroll_container[]`
    elements are not flattened.
 - `formspec_ast.show_formspec(player_or_name, formname, formspec)`: Similar
    to `minetest.show_formspec`, however also accepts player objects and will
    pass `formspec` through `formspec_ast.interpret` first.
 - `formspec_ast.safe_parse(string_or_tree)`: Similar to `formspec_ast.parse`,
    however will delete any elements that may crash the client (or any I
    haven't added to the safe element list). The safe element list that this
    function uses is very limited, it may break complex formspecs.
 - `formspec_ast.safe_interpret(string_or_tree)`: Equivalent to
    `formspec_ast.unparse(formspec_ast.safe_parse(string_or_tree))`.
 - `formspec_ast.formspec_escape(text)`: The same as `minetest.formspec_escape`,
    should only be used when formspec_ast is being embedded outside of Minetest.

## AST

The AST is similar (and generated from) [the formspec element list], however
all attributes are lowercase.

[the formspec element list]: https://minetest.gitlab.io/minetest/formspec/#elements

### Recent backwards incompatibilities

While I try to reduce backwards incompatibilities, sometimes they are necessary
to either fix bugs in formspec_ast or for implementing new formspec features.

#### April 2023

 - The `current_tab` value of tabheader elements is now parsed as a number.

#### February 2022

 - The value of scrollbars is now a number instead of a string.
 - The `item`, `listelem`, and `caption` fields are now `items`, `listelems`,
   and `captions`. The old names still work when unparsing formspecs for now
   but are no longer used when parsing formspecs.

#### March 2021

 - The `index_event` value for `dropdown` is now a boolean instead of a string.

#### February 2021

 - The `close_on_enter` value for `field_close_on_enter` is now a boolean
   instead of a string.
 - The `frame_count`, `frame_duration` and `frame_start` values in
   `animated_image` are now numbers.

#### September 2020

 - The `style[]` element has a `selectors` field instead of `name`. Using
   `name` when unparsing formspecs still works, however parsed formspecs
   always use `selectors`.

### Special cases

 - `formspec_version` (provided it is the first element) is moved to
    `tree.formspec_version` (`1` by default).

### `formspec_ast.parse` example

*Note that the whitespace in the formspec is optional and exists for
readability. Non-numeric table items in the `dump()` output are re-ordered for
readability.*

```lua
> tree = formspec_ast.parse('size[5,2] '
>>     .. 'style[name;bgcolor=blue;textcolor=yellow]'
>>     .. 'container[1,1]'
>>     .. '    label[0,0;Containers are fun]'
>>     .. '    container[-1,-1]'
>>     .. '        button[0.5,0;4,1;name;Label]'
>>     .. '    container_end[]'
>>     .. '    label[0,1;Nested containers work too.]'
>>     .. 'container_end[]'
>>     .. ' image[0,1;1,1;air.png]')
> print(dump(tree))
{
    formspec_version = 1,
    {
        type = "size",
        w = 5,
        h = 2,
    },
    {
        type = "style",
        selectors = {"name"},
        props = {
            bgcolor = "blue",
            textcolor = "yellow",
        },
    },
    {
        type = "container",
        x = 1,
        y = 1,
        {
            type = "label",
            x = 0,
            y = 0,
            label = "Containers are fun",
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
    },
    {
        type = "image",
        x = 0,
        y = 1,
        w = 1,
        h = 1,
        texture_name = "air.png",
    },
}

```

### `formspec_ast.flatten` example

```lua
> print(dump(formspec_ast.flatten(tree)))
{
    formspec_version = 1,
    {
        type = "size",
        w = 5,
        h = 2,
    },
    {
        type = "style",
        selectors = {"name"},
        props = {
            bgcolor = "blue",
            textcolor = "yellow",
        },
    },
    {
        type = "label",
        x = 1,
        y = 1,
        label = "Containers are fun",
    },
    {
        type = "button",
        x = 0.5,
        y = 0,
        w = 4
        h = 1,
        name = "name",
        label = "Label",
    },
    {
        type = "label",
        x = 1,
        y = 2,
        label = "Nested containers work too.",
    },
    {
        type = "image",
        x = 0,
        y = 1,
        w = 1,
        h = 1,
        texture_name = "air.png",
    },
}
```

### `formspec_ast.unparse` example

```lua
> print(formspec_ast.unparse(tree))
size[5,2,]style[name;textcolor=yellow;bgcolor=blue]container[1,1]label[0,0;Containers are fun]container[-1,-1]button[0.5,0;4,1;name;Label]container_end[]label[0,1;Nested containers work too.]container_end[]image[0,1;1,1;air.png]

> print(formspec_ast.unparse(formspec_ast.flatten(tree)))
size[5,2,]style[name;textcolor=yellow;bgcolor=blue]label[1,1;Containers are fun]button[0.5,0;4,1;name;Label]label[1,2;Nested containers work too.]image[0,1;1,1;air.png]
```
