# Vehicle Mash [![Build status](https://github.com/minetest-mods/vehicle_mash/workflows/build/badge.svg)](https://github.com/minetest-mods/vehicle_mash/actions) [![ContentDB](https://content.minetest.net/packages/Panquesito7/vehicle_mash/shields/downloads/)](https://content.minetest.net/packages/Panquesito7/vehicle_mash/)

- Current version: 2.3.0
- By [blert2112](https://github.com/blert2112), and handed over to [Panquesito7](https://github.com/Panquesito7).

![Screenshot](https://raw.githubusercontent.com/minetest-mods/vehicle_mash/master/screenshot.png)

A merge of all the vehicles from:

- "Mesecars" by paramat.
- "Car" by Esteban.
- "Boats" by PilzAdam.
- "Hovercraft" by Stuart Jones.

- 28 vehicles currently.
- All CAR01's can carry 3 passengers.

- Disable vehicles by going to your Minetest Settings.
- Adding new vehicles is a simple matter of:
  - Create/acquire vehicle model and textures.
  - Create, and name appropriately, a new `.lua` file on its appropiate folder for the vehicle based on one of the existing ones.
  - Add a setting in `settingtypes.txt` for users to enable/disable it.
  - Change settings in the file you created to reflect the new vehicle.
  - Add a new line to `init.lua` to load the vehicle `dofile(minetest.get_modpath("vehicle_mash") .. "/NAME_OF_VEHICLE.lua")`

## Installation

- Unzip the archive, rename the folder to `vehicle_mash` and place it in
../minetest/mods/

- GNU/Linux: If you use a system-wide installation place
it in ~/.minetest/mods/.

- If you only want this to be used in a single world, place
the folder in worldmods/ in your world directory.

For further information or help, see:\
<https://wiki.minetest.net/Installing_Mods>

## Known issues

- Attachments incorrectly ordered.

## License

Copyright (C) 2015-2016 blert2112 and contributors\
Copyright (C) 2019-2022 Panquesito7 (halfpacho@gmail.com) and contributors

All licenses of previous works, of course, apply (see credits below).
As far as the work I did... It's really just a fork of a fork of a fork of a fork, tossed it all into a blender and spun it on puree for a bit. Baked it for a while and set it on the counter to cool. What I mean is, make what you will of it, it matters not to me.

See [`LICENSE.md`](LICENSE.md) for more information.

## Dependencies

- `default` (included in [Minetest Game](https://github.com/minetest/minetest_game))
- [`lib_mount`](https://github.com/minetest-mods/lib_mount)

## Requirements

- `vehicle_mash` 2.1.0 for MT 5.0.0+.
- `vehicle_mash` 2.0 for MT 0.4.12+ (may work on older versions).

## TODO

There are no pending tasks to do yet.

## Changelog

v2.3.0 2/12/2021

- Improved formatting in `README.md`.
- Added [API Mode](https://github.com/minetest-mods/vehicle_mash/commit/6b3bdac4d880a6fde298a286b3bd5043750e904e) setting.
- Removed F1 and 126r cars due to closed-source license.
- Improved vehicle drops.
  - Vehicles can now drop multiple items.
- Add option for vehicles to fly (setting per vehicle).
- Can enable/disable crash separately for each vehicle.
- Added ContentDB badge on `README.md`.
- Improved GitHub workflow.

v2.2.2 6/02/2020

- Fix passengers not detaching when driver gets out.
- Various other tweaks and fixes for passengers.

v2.2.1 5/28/2020

- Added vehicle crafting (Enabled by default).
  - Added car battery, windshield, tire, and motor.
- All CAR01's can now carry 3 passengers.
- Add `screenshot.png`.
- Improve `README.md`.

v2.2 5/15/2020

- Move files to a folder of its own.
- Add GitHub workflow and LuaCheck.
- Add `settingtypes.txt` to select enabled cars.
- Improve `README.md`.
- Short a bit the code.

v2.1 6/10/2019

- Fix attachment positions for drivers/passengers on all vehicles.
- Adds red, green, and yellow hovercrafts.
- Use `mod.conf` for name, description and dependencies.
- Support for MT 5.0.0+.

v2.0 8/13/2016

- converted to use the lib_mount mod for "driving"
- enlarged F1 and 126r models x2.5
- added yellow Mesecar
- updated boat model from default boat mod
- various speed/braking/turning/acceleration tweaks
- various collision box tweaks
- various other tweaks I probably forgot about
- last version supporting MT 0.4.12+.

v1.4 5/19/2015

- attach (one) passenger added
- reorganized vehicle definition file code and added some variables pertaining to passengers
- added a vehicle definition file template with comments
- cleaned up to remove code dulplication

v1.3 5/5/2015

- player now sits forward in vehicles
- tweaked player sit positions
- tweaked collison boxes
- proper placement on_ground/in_water

v1.2 5/1/2015

- added boats
- changed name so  to not conflict with other mods

v1.1 4/25/2015

- car won't come to a complete stop (fixed)

v1.0 4/24/2015

- first release

## Bugs, suggestions and new features

Report bugs or suggest ideas by [creating an issue](https://github.com/minetest-mods/vehicle_mash/issues/new).\
If you know how to fix an issue, consider opening a [pull request](https://github.com/minetest-mods/vehicle_mash/compare).
