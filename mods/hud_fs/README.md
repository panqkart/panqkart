# hud_fs

A Minetest mod library to make handling formspec-like HUDs easier. Depends on
[formspec_ast](https://content.minetest.net/packages/luk3yx/formspec_ast/).

## API

 - `hud_fs.show_hud(player, formname, formspec)`: Displays or updates a HUD
    with the specified formname and formspec.
    - `formspec` can also be a formspec_ast tree for more advanced usage.
 - `hud_fs.close_hud(player, formname)`: Closes `formname`. Equivalent to
    `hud_fs.show_hud(player, formname, "")`.

The player parameter in the above function can either be a player object or a
player name.

*If you just want to manage HUDs, that's all you need to know!* Don't worry
about trying to get incremental updates or tracking HUD IDs, `hud_fs` does that
for you behind-the-scenes.

### Supported formspec features

All formspecs are assumed to be version 3 and the `formspec_version` element
(if any) is ignored.

The following elements are supported:

 - `size`
    - While there is no background for the HUD, this does change where the
      co-ordinates start from.
 - `position`, `anchor`
    - **You need to use these to set the position of the HUD!**
    - See [the Minetest API documentation](https://minetest.gitlab.io/minetest/formspec/#positionxy) for more info.
    - You probably want `anchor` to have the same value as `position`.
 - `container`
 - `label`
    - Because of HUD limitations, `minetest.colorize()` only works at the start
      of the label.
 - `image`
 - `box`
 - `textarea`
    - If the name is non-empty a background is drawn behind the text.
    - Text will overflow vertically outside the specified height.
 - `item_image`
    - Only works with some nodes, should work with all craftitems.
 - `button`, `button_exit`, `image_button`, `image_button_exit`,
   `item_image_button`
    - Buttons become a grey box with a label in the middle.
    - The label has the same limitations as the `label` element.
    - The `noclip` option is ignored.
    - Item image buttons have the same limitations as `item_image`.

All valid formspec elements not listed above are ignored.

### Advanced API

 - `hud_fs.set_scale(formname, scale)`: Sets the scale of the HUD.
    - All future HUDs shown with `formname` will use this scale instead of the
      default (64, subject to change).
    - The scale is the amount of pixels per co-ordinate. For example, a 1x1
      image will have a size of 10x10 pixels if the scale is set to 10.
 - `hud_fs.set_z_index(formname, z_index)`: Sets the base Z-Index of the HUD.
    - All future HUDs shown with `formname` will use this z-index instead of
      the default (0).
    - The HUD will use z-index values from `z_index` to
        `z_index + amount_of_hud_elements`.
    - This won't work properly with Minetest clients older than 5.2.0.


## FAQ(?)

#### Why not implement this mod in the Minetest engine?

This mod (or anything similar) won't be implemented, a proposal to do so was
rejected in https://github.com/minetest/minetest/issues/10135.

#### Why formspecs?

 - There isn't a complicated new API to learn, if you write MT mods you
   probably know how to use formspecs already.
 - I have a [web-based formspec editor] which can now be used to design HUDs
   for use with this mod.
 - You don't need any knowledge of Minetest's HUD API to use this mod.
 - As this mod parses formspecs server-side, the lack of differential updates
   is for the most part a non-issue.

[web-based formspec editor]: https://git.minetest.land/luk3yx/formspec-editor

#### But I hate formspecs and don't want to touch them

Then don't use this mod. There are plenty of other HUD library mods around such
as [hudlib](https://github.com/octacian/hudlib) and
[panel_lib](https://gitlab.com/zughy-friends-minetest/panel_lib).

## Performance

If this mod becomes a performance bottleneck you can try the following things:

 - Move any formspec elements that are added or removed frequently to the end
   of the formspec. This will allow them to be removed without touching other
   elements internally.
    - This mod is currently inefficient at updating HUDs when elements are
      added or removed when they aren't at the end of the formspec.
 - Using a formspec_ast tree instead of a formspec in show_hud. `formspec_ast`
   is relatively slow at parsing formspecs at the time of writing.
 - Don't call show_hud when you already know that nothing has changed. Doing so
   will waste time parsing the formspec, converting it to HUD elements, then
   figuring out what has changed.
