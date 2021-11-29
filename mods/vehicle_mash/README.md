# Vehicle Mash [![Build status](https://github.com/Panquesito7/vehicle_mash/workflows/build/badge.svg)](https://github.com/Panquesito7/vehicle_mash/actions)

- Current version: 2.2.1
- By [blert2112](https://github.com/blert2112), and improvements by [Panquesito7](https://github.com/Panquesito7).

![Screenshot](https://raw.githubusercontent.com/Panquesito7/vehicle_mash/master/screenshot.png)

A merge of all the vehicles from:
* "Cars" by Radoslaw Slowik.
* "Mesecars" by paramat.
* "Car" by Esteban.
* "Boats" by PilzAdam.
* "Hovercraft" by Stuart Jones.

- 30 vehicles currently.
- All CAR01's can carry 3 passengers.

* Disable vehicles by going to your Minetest Settings.
* Adding new vehicles is a simple matter of:
	* Create/acquire vehicle model and textures.
	* Create, and name appropriately, a new `.lua` file on its appropiate folder for the vehicle based on one of the existing ones.
	* Add a setting in `settingtypes.txt` for users to enable/disable it.
	* Change settings in the file you created to reflect the new vehicle.
	* Add a new line to `init.lua` to load the vehicle `dofile(minetest.get_modpath("vehicle_mash") .. "/NAME_OF_VEHICLE.lua")`

## Installation
- Unzip the archive, rename the folder to `vehicle_mash` and place it in
../minetest/mods/

- GNU/Linux: If you use a system-wide installation place
it in ~/.minetest/mods/.

- If you only want this to be used in a single world, place
the folder in worldmods/ in your world directory.

For further information or help, see:\
https://wiki.minetest.net/Installing_Mods

## Known issues
- When there is more than 1 passenger, and the driver gets out, one or more players will stay attached to the vehicle.

## License
All licenses of previous works, of course, apply. (see credits below)
As far as the work I did... It's really just a fork of a fork of a fork of a fork, tossed it all into a blender and spun it on puree for a bit. Baked it for a while and set it on the counter to cool. What I mean is, make what you will of it, it matters not to me.

See [`LICENSE.md`](LICENSE.md) for more information.

## Dependencies
- `default` (included in [Minetest Game](https://github.com/minetest/minetest_game))
- [`lib_mount`](https://github.com/Panquesito7/lib_mount)

## Requirements
- `vehicle_mash` 2.1.0 for MT 5.0.0+.
- `vehicle_mash` 2.0 for MT 0.4.12+ (may work on older versions).

## TODO
There are no pending tasks to do yet.

## Changelog

v2.2.1 5/28/2020

* Added vehicle crafting (Enabled by default).
  * Added car battery, windshield, tire, and motor.
* All CAR01's can now carry 3 passengers.
* Add `screenshot.png`.
* Improve `README.md`.

v2.2 5/15/2020

* Move files to a folder of its own.
* Add GitHub workflow and LuaCheck.
* Add `settingtypes.txt` to select enabled cars.
* Improve `README.md`.
* Short a bit the code.

v2.1 6/10/2019

*	 Fix attachment positions for drivers/passengers on all vehicles.
*	 Adds red, green, and yellow hovercrafts.
*	 Use `mod.conf` for name, description and dependencies.
*	 Support for MT 5.0.0+.
	
	
v2.0 8/13/2016

*	 converted to use the lib_mount mod for "driving"
*	 enlarged F1 and 126r models x2.5
*	 added yellow Mesecar
*	 updated boat model from default boat mod
*	 various speed/braking/turning/acceleration tweaks
*	 various collision box tweaks
*	 various other tweaks I probably forgot about
*	 last version supporting MT 0.4.12+.
	
		
v1.4 5/19/2015

*	 attach (one) passenger added
*	 reorganized vehicle definition file code and added some variables pertaining to passengers
*	 added a vehicle definition file template with comments
*	 cleaned up to remove code dulplication
	
	
v1.3 5/5/2015

*	 player now sits forward in vehicles
*	 tweaked player sit positions
*	 tweaked collison boxes
*	 proper placement on_ground/in_water
	
	
v1.2 5/1/2015

*	 added boats
*	 changed name so  to not conflict with other mods
	
	
v1.1 4/25/2015

*	 car won't come to a complete stop (fixed)
	
	
v1.0 4/24/2015

*	first release



## Bugs, suggestions and new features
Report bugs or suggest ideas by [creating an issue](https://github.com/blert2112/vehicle_mash/issues/new).      
If you know how to fix an issue, consider opening a [pull request](https://github.com/blert2112/vehicle_mash/compare).

## Credit where credit is due
- F1 and 126R cars from: "Cars" by Radoslaw Slowik
	- https://forum.minetest.net/viewtopic.php?f=9&t=8698
	- License: Code WTFPL, modeles/textures CC BY-NC-ND 4.0

- Black, Blue, Brown, Cyan, Dark Green, Dark Grey, Green, Grey, Magenta, Orange, Pink, Red, Violet, White, Yellow, Hot Rod, Nyan Ride, Oerkki Bliss, and Road Master from: "Car" by Esteban
	- https://forum.minetest.net/viewtopic.php?f=13&t=7407
	- License:
		- No info given in that mod but I am going to assume the credit for the original model goes to:
		- Melcor and his CAR01 model
		- https://forum.minetest.net/viewtopic.php?f=9&t=6512
		- License: CC-BY-NC-SA

- MeseCars from: "Mesecars" by paramat
	- https://forum.minetest.net/viewtopic.php?f=11&t=7967
	- Licenses: Code WTFPL, textures CC BY-SA

- Boats from "Boats" by PilzAdam
	- textures: Zeg9
	- model: thetoon and Zeg9, modified by PavelS(SokolovPavel)
	- License: WTFPL

- Hovercraft from "Hovercraft" by Stuart Jones
	- Licenses:
		- textures: CC-BY-SA
		- sounds: freesound.org
			- Rocket Boost Engine Loop by qubodup - CC0
			- CARTOON-BING-LOW by kantouth - CC-BY-3.0
			- All other sounds: Copyright Stuart Jones - CC-BY-SA

I am sure many others deserve mention.\
If you feel left out let me know and I will add you in.

Enjoy!
