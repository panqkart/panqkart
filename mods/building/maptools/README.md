# Map Tools [![](https://github.com/minetest-mods/maptools/workflows/build/badge.svg)](https://github.com/minetest-mods/maptools/actions)

Map Tools for [Minetest](https://www.minetest.net/), a free and open source infinite
world block sandbox game.

## Resources

- [Forum topic](https://forum.minetest.net/viewtopic.php?f=11&t=1882)
- [List of nodes and items available](docs/NODES_ITEMS.md)

## Installation

### Download the mod

To install Map Tools, clone this Git repository into your Minetest's `mods/`
directory:

```bash
git clone https://github.com/minetest-mods/maptools.git
```

You can also
[download a ZIP archive](https://github.com/minetest-mods/maptools/archive/master.zip)
of Map Tools.

### Enable the mod

Once you have installed Map Tools, you need to enable it in Minetest.
The procedure is as follows:

#### Using the client's main menu

This is the easiest way to enable Map Tools when playing in singleplayer
(or on a server hosted from a client).

1. Start Minetest and switch to the **Local Game** tab.
2. Select the world you want to enable Map Tools in.
3. Click **Configure**, then enable `maptools` by double-clicking it
   (or ticking the **Enabled** checkbox).
4. Save the changes, then start a game on the world you enabled Map Tools on.
5. Map Tools should now be running on your world.

#### Using a text editor

This is the recommended way to enable the mod on a server without using a GUI.

1. Make sure Minetest is not currently running (otherwise, it will overwrite
   the changes when exiting).
2. Open the world's `world.mt` file using a text editor.
3. Add the following line at the end of the file:

```text
load_mod_maptools = true
```

If the line is already present in the file, then replace `false` with `true`
on that line.

4. Save the file, then start a game on the world you enabled Map Tools on.
5. Map Tools should now be running on your world.

## Version compatibility

Map Tools is currently primarily tested with Minetest 5.1.0.
It may or may not work with newer or older versions. Issues arising in older
versions than 5.0.0 will generally not be fixed.

## License

Copyright © 2012-2020 Hugo Locurcio and contributors

- Map Tools code is licensed under the zlib license, see
  [`LICENSE.md`](LICENSE.md) for details.
- Unless otherwise specified, Map Tools textures are licensed under
  [CC BY-SA 3.0 Unported](https://creativecommons.org/licenses/by-sa/3.0/).
