# 🏰 Setting up the lobby/game

### ❗ This is no longer required as of [v0.2.0](https://github.com/panqkart/panqkart/releases/v0.2.0) if `manual_setup` is disabled in the Minetest settings ❗

We've made a lobby for players to hang out, have fun, search for prizes, and so much more.\
You can, later on, join a race from a special part of the lobby if you want to play!

**Before getting started, please download the [Mobs Redo](https://notabug.org/TenPlus1/mobs_redo) mod or the\
[Server Mods](https://github.com/panqkart/servermods) modpack which already includes it and other server-special functionalities.**

So now, let's get started to set up the lobby!\
In this section, we will setup our made lobby.

## 🛠 Downloading the repository and loading the lobby

You need to download this repository. If you are experienced with Git, you will need to clone this and its submodules.

```bash
git clone --recurse-submodules https://github.com/panqkart/panqkart
```

If you don't know anything about Git, you can download PanqKart via the [ContentDB](https://content.minetest.net/packages/Panquesito7/panqkart/) on the\
web or directly in Minetest, which results in much easier and clones all submodules automatically.

## 🌎 Installing WorldEdit in Minetest

You will need to install the [`WorldEdit`](https://github.com/Uberi/Minetest-WorldEdit) mod to add the lobby and the level.

Make a new world, with any name you want, with the mapgen set to `singlenode`, for the game `panqkart`. When joining, you will need to grant yourself all the privileges in order to fly and insert our pre-made lobby. Choose an area where you want to place the lobby by selecting position 1 and position 2. If you're unsure how to do this, check the [WorldEdit tutorial](https://github.com/Uberi/Minetest-WorldEdit/blob/master/Tutorial.md).

## 💻 Adding the schematic to your world 💻

On the `panqkart` folder, you'll see a `schematics` folder. You will see a `lobby.we` file.\
Now, make a folder in your **world's directory** named `schems`, which can and will be accessed by WorldEdit.

If your world is named `my_world`, you should see a folder named `my_world` in the `../minetest/worlds` directory.\
There is where you need to create the `schems` folder. That is how WorldEdit will access the `lobby.we` file.

Copy and paste the `lobby.we` file into the `schems` folder in your world directory.\
You're done pasting the lobby file into your world. Now, we must insert that file into our world.

If you already selected the area (we recommend placing position 1 and position 2 at the same position), you will need to go to your<br> inventory (by clicking on `i`), go to the `Creation` tab, then click on the [![inventory_plus_worldedit_gui](https://user-images.githubusercontent.com/51391473/171032521-cd536e49-e3f0-4784-95a1-5b6917a21fe4.png)](https://github.com/Uberi/Minetest-WorldEdit/blob/master/worldedit_gui/textures/inventory_plus_worldedit_gui.png)
 WorldEdit icon.

Now that you're on that page, click on `Save/Load`. It will ask you the name of the file you want to load. `lobby.we` is the name we will load. Once you click on `Load`, boom! The lobby will be there now. 🎉<br>
You will have to do some minor changes in order to make the lobby work properly. We will help you do it in the guide below.

## 🗺 Configuring the spawnpoint

There's a spawn node defined by `pk_nodes` used to define the spawnpoint when you place it or either when it's loaded ([LBM](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt#L7937)).\
**Do not attempt to place two or more of this node, as the system will get confused with two spawnpoints.**

**When placing the schematic, the spawn position is already defined and it does not require extra setup.**\
**However, if you want to change the position yourself for any reason, feel free to check the steps below.**

You can either keep the spawnpoint as-is or change it via the Minetest settings:

1. Open Minetest.
2. Go to the `Settings` tab.
3. Go to `All settings`.
4. Click on the `Games` dropdown.
5. Click on the `PanqKart` dropdown.
6. Double-click on the `Default lobby position`/`lobby_position` setting.
7. Set the lobby position to your liking, using the format `(<x,y,z>)`.

_Please note that once you change the spawnpoint position, the spawnpoint node position will be ignored._

You're done now! The lobby is now set up 🎉 You can now play on LAN, add new features, or just try it out for yourself!\
If you have any more questions or need any more help, feel free to reach us at `halfpacho@gmail.com` or in our [Discord community](https://discord.gg/HEweZuF3Vv).

## 🏞 Setting up the level

Once you have the lobby, you will need to setup the level to play, otherwise, it'd be just boring without playing.\
So below here, we will explain how to add the level to your map!

If you've already downloaded the repository, look out in the `schematics` folder.\
There should be a file named `level.we` there. You can follow the steps above for how to load the level.

**WARNING:** The level is very big! We recommend putting it far away from the lobby or other buildings you have around. It might take up to 10 minutes for the level to be 100% loaded. If it's not being loaded, try re-joining your world.

Once you've set up the level, well, you're practically done now. You just need to configure the `start_race` node, which can be found\
on the lobby, on the stonebrick tunnel. Right-click on it, and set positions for 1st player, 2nd player, 3rd player, and all the way to 12.
